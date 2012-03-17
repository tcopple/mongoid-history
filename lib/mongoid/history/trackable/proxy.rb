module Mongoid::History::Trackable
  class Proxy
    attr_accessor :doc, :association_chain

    def initialize(doc)
      @doc = doc
      @association_chain = AssociationChain.new(doc)
    end

    def meta
      @meta ||= Mongoid::History.metadata(doc.class.name)
    end

    def doc_version
      doc.send(meta.version_field || 0)
    end

    def increment_doc_version
      doc.send "#{meta.version_field}=", doc_version+1
    end

    def can_track?(action)
      return meta.tracking? unless action == :update
      meta.tracking? && doc.changed.blank?
    end

    def track!(action)
      return unless can_track?(action)
      increment_doc_version
      meta.tracker.create!(tracker_attributes(action))
    end

    def tracker_attributes(method)
      journal.on(method).results.merge({
        :association_chain  => association_chain.to_a,
        :scope              => meta.scope,
        :modifier           => doc.send(modifier_field),
        :version            => doc_version,
        :action             => action
      })
    end

    def history
      meta.tracker.where(
        :scope              => meta.scope,
        :association_chain  => association_chain.to_a
      )
    end

    def undo!(*args)

    end

    def redo!(*args)

    end
  end
end
