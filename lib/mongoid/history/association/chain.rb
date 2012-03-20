module Mongoid::History::Association
  class Chain < Array
    class << self
      def build_from_array(array)
        ArrayBuilder.new(array).build
      end

      def build_from_doc(doc)
        DocumentBuilder.new(doc).build
      end
    end

    def leaf
      last
    end

    def root
      first
    end

    def parents
      self[0..-2]
    end

    def parent
      parents.last
    end

    def to_a
      map(&:to_hash)
    end

  end
end
