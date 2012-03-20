module Mongoid::History
  class AssociationChain
    class Iterator
      attr_reader :current_node
      def initialize(node)
        @current_node = node
      end

      def doc
        @current_node.doc
      end

      def parent
        @current_node = Mongoid::History::AssociationChain::DocumentConverter.new(doc._parent).node if parent?
      end

      def parent?
        !!doc._parent
      end

      def child(hash)
        return nil unless hash
        @current_node = Mongoid::History::AssociationChain::Node.new(hash['name'], hash['id'], child_doc(hash))
      end

      def child?(hash)
        !!child_doc(hash)
      end

      # @private
      def child_doc(hash)
        id    = hash["id"]
        name  = hash["name"]

        if embeds_one?(name)
          doc.send(name)
        elsif embeds_many?(name)
          doc.send(name).where(:_id => id).first
        else
          nil
        end
      end

      # @private
      def child_association(name)
        doc.reflect_on_association(name)
      end

      # @private
       def child_association_type(name)
        assoc = child_association(name)
        assoc ? assoc.relation : nil
      end

      # @private
       def embeds_one?(name)
        child_association_type(name) == Mongoid::Relations::Embedded::One
      end

      # @private
       def embeds_many?(name)
        child_association_type(name) == Mongoid::Relations::Embedded::Many
      end
    end
  end
end
