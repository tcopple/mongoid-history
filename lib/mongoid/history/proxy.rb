module Mongoid::History
  class Proxy
    attr_accessor :doc, :association_chain

    def initialize(doc)
      @doc = doc
    end

    def track!(action)
      Operation::Track.new(doc).execute!
    end

    def undo!(modifier, options_or_version)
      Operation::Undo.new(doc, modifier, options_or_version).execute!
    end

    def redo!(modifier, options_or_version)
      Operation::Redo.new(doc, modifier, options_or_version).execute!
    end

    def history
      meta.tracker.where(
        :scope              => meta.scope,
        :association_chain  => association_chain.root.to_hash
      )
    end

    # private methods below
    def meta
      @meta ||= Mongoid::History.meta(doc.class)
    end

    def association_chain
      @association_chain ||= Association::Chain.build_from_doc(doc)
    end
  end
end
