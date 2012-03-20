module Mongoid::History
  class AssociationChain
    class Node
      attr_reader :doc

      def self.root(hash)
        klass = hash['name'].constantize
        doc = klass.where(:_id => hash['id']).first
        doc ? new(doc) : nil
      end

      def initialize(doc)
        @doc = doc
      end

      def id
        doc.id
      end

      def name
        association_name || model_name
      end

      def to_hash
        { 'name' => name, 'id' => id }
      end

      def ==(another)
        doc.equal? another.doc
      end

      # @private
      def association_name
        assoc = parent_association
        assoc && assoc.inverse.to_s
      end

      # @private
      def parent_association
        return nil unless @doc._parent
        @doc.reflect_on_all_associations(:embedded_in).find do |assoc|
          @doc._parent == @doc.send(assoc.key)
        end
      end

      # @private
      def model_name
        doc.class.name
      end
    end
  end
end
