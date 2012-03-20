module Mongoid::History::Association
  class Node
    class << self
      def parent_association_name(doc)
        assoc = parent_association
        assoc && assoc.inverse.to_s
      end

      def parent_association(doc)
        return nil unless doc && doc._parent
        doc.reflect_on_all_associations(:embedded_in).find do |assoc|
          doc._parent == doc.send(assoc.key)
        end
      end
    end

    attr_reader :name, :id, :doc
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

    def embeds_one?(name)
      child_association_type(name) == Mongoid::Relations::Embedded::One
    end

    def embeds_many?(name)
      child_association_type(name) == Mongoid::Relations::Embedded::Many
    end

    def child_association(name)
      doc.reflect_on_association(name)
    end

    def child_association_type(name)
      assoc = child_association(name)
      assoc ? assoc.relation : nil
    end

    def has_parent?
      !!doc._parent
    end

    def parent_id
      doc._parent && doc._parent.id
    end
  end
end
