module Mongoid::History::Association
  class Node
    attr_reader :name, :id, :class_name, :doc
    def initialize(name, id, class_name, doc)
      @name = name
      @class_name = class_name
      @id = id
      @doc = doc
    end

    def to_hash
      { 'name' => name, 'id' => id, 'class_name' => class_name }
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
  end
end
