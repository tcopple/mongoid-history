module Mongoid::History
  class AssociationChain
    include Mongoid::Fields::Serializable

    attr_reader :nodes, :root, :leaf

    def initialize(doc_or_array)
      if doc_or_array.is_a?(Array)
        @array = doc_or_array
        root = Node.root array.first
        walk_from_root! root, array[1..-1]
      else
        doc = doc_or_array
        leaf = DocumentConverter.new(doc).node
        walk_from_leaf! leaf
      end
    end

    def walk_from_root!(root, array)
      iterator  = Iterator.new root
      @nodes    = [root]
      array.each do |hash|
        @nodes.push iterator.child(array.shift)
      end
    end

    def walk_from_leaf!(leaf)
      iterator  = Iterator.new leaf
      @nodes    = [leaf]
      while node = iterator.parent
        @nodes.unshift node
      end
    end

    def parents
      nodes[0..-2]
    end

    def parent
      parents.last
    end

    def leaf
      @leaf ||= nodes.last
    end

    def root
      @root ||= nodes.first
    end

    def length
      nodes.length
    end

    def root_class
      array.first['name'].constantize
    end

    def array
      @array ||= nodes.map(&:to_hash)
    end
    alias :to_a :array

    def serialize(chain)
      chain.to_a if chain
    end

    def deserialize(array)
      self.class.new(array)
    end
  end
end
