module Mongoid::History
  class AssociationChain
    class Node
      attr_reader :name, :id, :doc

      def self.root(hash)
        klass = hash['name'].constantize
        doc = klass.where(:_id => hash['id']).first
        new(hash['name'], hash['id'], doc)
      end

      def self.from_doc(doc)
        DocumentCoverter.new(doc).node
      end

      def initialize(name, id, doc)
        @name = name
        @id = id
        @doc = doc
      end

      def to_hash
        { 'name' => name, 'id' => id }
      end

      def ==(another)
        id.equal?(another.id) && name.equal?(another.name?)
      end
    end
  end
end
