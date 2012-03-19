module Mongoid::History
  class AssociationChain
    include Mongoid::Fields::Serializable

    attr_reader :nodes, :root, :leaf

    def initialize(doc_or_array)
      if doc_or_array.is_a?(Array)
        array = doc_or_array
        root = Node.root array.first
        walk_from_root! root, array[1..-1]
      else
        doc = doc_or_array
        leaf = Node.new doc
        walk_from_leaf! leaf
      end
    end

    def walk_from_root!(root, array)
      iterator  = Iterator.new root
      @nodes    = [root]
      while node = iterator.child(array.shift)
        @nodes.push node
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
      nodes[0..-1]
    end

    def leaf
      @leaf ||= nodes.last
    end

    def root
      @root ||= nodes.first
    end

    def to_a
      nodes.map(&:to_hash)
    end

    def serialize(chain)
      chain.to_a if chain
    end

    def deserialize(array)
      self.class.new(array)
    end
  end
end
