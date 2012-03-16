module Mongoid::History::Trackable::ActiveSupport
  extend ActiveSupport::Concern

  module ClassMethods
    def track_history(opts={})
      meta = Mongoid::History::Trackable::Metadata.new(self, opts)
      Mongoid::History.register(self, meta)

      field meta.version_field, :type => Integer
      referenced_in meta.modifier_field, :class_name => meta.modifier_class_name

      include MyInstanceMethods
      extend  SingletonMethods
      before_update     :track_update
      before_create     :track_create
      before_destroy    :track_destroy
    end
  end

  module MyInstanceMethods
    def tracking_visitor
      @tracking_visitor ||= Mongoid::History::Trackable::Visitor.new(self)
    end

    def track_update
      tracking_visitor.visit_tracking!('update')
    end

    def track_create
      tracking_visitor.visit_tracking!('create')
    end

    def track_destroy
      tracking_visitor.visit_tracking!('destroy')
    end

    def undo!
      tracking_visitor.visit_undo
    end

    def redo!(*args)
      tracking_visitor.visit_redo
    end

  end

  module SingletonMethods
  end
end
