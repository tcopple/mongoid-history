module Mongoid::History
  class AssociationChain
    class DocumentConverter
      attr_reader :doc
      def initialize(doc)
        @doc = doc
      end

      def parent_association_name
        assoc = parent_association
        assoc && assoc.inverse.to_s
      end

      def parent_association
        return nil unless doc._parent
        doc.reflect_on_all_associations(:embedded_in).find do |assoc|
          doc._parent == doc.send(assoc.key)
        end
      end

      def model_name
        doc.class.name
      end

      def name
        parent_association_name || model_name
      end

      def id
        doc.id
      end

      def node
        Node.new(name, id, doc)
      end
    end
  end
end
