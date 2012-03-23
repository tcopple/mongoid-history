module Mongoid::History::Operation
  class Abstract
    include Mongoid::History::Helper

    attr_reader :doc
    def initialize(doc)
      @doc = doc
    end
  end
end
