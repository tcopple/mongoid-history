module Mongoid::History::Track
  class Builder
    attr_reader :doc, :action
    def initialize(doc, action)
      @doc    = doc
      @action = action
    end

    def history_delta
      @history_delta ||= Mongoid::History::Delta.new(doc)
    end

    def association_chain
      @association_chain ||= Mongoid::History::Association::Chain.build_from_doc(doc)
    end

    def meta
      @meta ||= Mongoid::History.meta(doc.class)
    end

    def switch
      @switch ||= Mongoid::History.switch(doc.class)
    end

    def modifier
      doc.send(meta.modifier_field)
    end

    def version
      doc.send(meta.version_field) || 0
    end

    def attributes
      original, modified = history_delta.on(action).results

      return if original.blank? && modified.blank?

      {
        :association_chain  => association_chain,
        :scope              => meta.scope,
        :original           => original,
        :modified           => modified,
        :modifier           => modifier,
        :version            => version,
        :action             => action
      }
    end

    def build
      attr = attributes
      meta.tracker.new(attr) if attr
    end
  end
end
