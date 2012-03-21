class Mongoid::History::Delta
  class AbstractState
    attr_reader :doc
    def initialize(doc)
      @doc = doc
    end

    # should return [original, :modified]
    def results
    end
  end
end
