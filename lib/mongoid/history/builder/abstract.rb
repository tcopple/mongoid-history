module Mongoid::History::Builder
  class Abstract
    include Mongoid::History::Helper

    attr_reader :doc
    def initialize(doc)
      @doc   = doc
    end
  end
end
