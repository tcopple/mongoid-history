module Mongoid::History::Association
  class Field
    include Mongoid::Fields::Serializable

    def serialize(chain)
      chain.to_a if chain
    end

    def deserialize(array)
      Chain.build_from_array(array)
    end
  end
end
