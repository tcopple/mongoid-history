module Mongoid::History
  class Proxy
    include Helper

    attr_accessor :doc, :association_chain

    def initialize(doc)
      @doc = doc
    end

    def track!(action)
      Operation::Track.new(doc).execute!(action)
    end

    def undo!(modifier, options_or_version)
      Operation::Undo.new(doc).execute!(modifier, options_or_version)
    end

    def redo!(modifier, options_or_version)
      Operation::Redo.new(doc).execute!(modifier, options_or_version)
    end

    def history
      meta.tracker.where(
        :scope              => meta.scope,
        :association_chain  => association_chain.root.to_hash
      )
    end


  end
end
