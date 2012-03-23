class Mongoid::History::Delta
  class AbstractState
    include Mongoid::History::Helper

    attr_reader :doc
    def initialize(doc)
      @doc = doc
    end

    # should return [original, :modified]
    def results
    end
  end
end
