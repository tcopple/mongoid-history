module Mongoid::History
  module Tracker
    extend ActiveSupport::Concern

    included do
      include Mongoid::Document
      include Mongoid::Timestamps
      attr_writer :trackable

      field :association_chain, :type => Mongoid::History::Association::Field
      field :modified,          :type => Hash
      field :original,          :type => Hash
      field :version,           :type => Integer
      field :action,            :type => String
      field :scope,             :type => String

      referenced_in :modifier, :class_name => Mongoid::History.modifier_class_name

      Mongoid::History.tracker_class = self
      Sweeper.hook!
    end

    def undo!(modifier)
      if action.to_sym == :destroy
        re_create
      elsif action.to_sym == :create
        re_destroy
      else
        trackable.update_attributes!(undo_attr(modifier))
      end
    end

    def redo!(modifier)
      if action.to_sym == :destroy
        re_destroy # really?? What good is track destroy TWICE??
      elsif action.to_sym == :create
        re_create # really?? Creating TWICE...?
      else
        trackable.update_attributes!(redo_attr(modifier))
      end
    end

    def trackable
      association_chain.leaf.doc
    end

private

    def re_create
      association_chain.length > 1 ? create_on_parent : create_standalone
    end

    def re_destroy
      trackable.destroy
    end

    def create_standalone
      model = association_chain.root.name.constantize
      restored = model.new(modified)
      restored.save!
    end

    def create_on_parent
      parent  = association_chain.parent
      child   = association_chain.leaf

      if parent.embeds_one?(child.name)
        parent.doc.send("create_#{child.name}!", modified)
      elsif parent.embeds_many?(child.name)
        parent.doc.send(child.name).create!(modified)
      else
        raise "This should never happen. Please report bug!"
      end
    end
  end
end
