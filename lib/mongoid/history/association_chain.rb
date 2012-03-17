module Mongoid::History
  class AssociationChain
    class Node
      attr_reader :doc
      def initialize(doc)
        @doc = doc
      end

      def parent
        @parent ||= @doc._parent ? self.class.new(@doc._parent) : nil
      end

      def parent_association
        @parent_association ||= get_parent_association
      end

      def association_name
        parent_association && parent_association.inverse.to_s
      end

      def get_parent_association
        return nil unless @doc._parent
        @doc.reflect_on_all_associations(:embedded_in).find do |assoc|
          @doc._parent == @doc.send(assoc.key)
        end
      end

      def model_name
        doc.class.name
      end

      def name
        association_name || model_name
      end

      def to_hash
        { 'name' => name, 'id' => @doc.id }
      end

      def ==(another)
        doc.equal? another.doc
      end
    end

    attr_reader :root
    def initialize(doc)
      @root = Node.new doc
    end

    def nodes
      @nodes ||= walk_nodes(@root)
    end

    def walk_nodes(node)
      node.parent ? walk_nodes(node.parent).push(node) : [node]
    end

    def to_a
      nodes.map(&:to_hash)
    end
  end
end
