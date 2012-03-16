module Mongoid::History::Tracker
  module Helper
    def association_hash(node)
      name = parent_association_name(node) || node.class.name
      { 'name' => name, 'id' => node.id}
    end

    def parent_association_metadata(node)
      node.reflect_on_all_associations(:embedded_in).find do |assoc|
        node._parent == node.send assoc.key
      end if node._parent
    end

    def parent_association_name(node)
      assoc = parent_association_metadata(node)
      assoc && assoc.inverse.to_s
    end

    def association_chain(node)
      list = node._parent ? association_chain(node._parent) : []
      list << association_hash(node)
      list
    end
  end
end
