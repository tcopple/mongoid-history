class Mongoid::History::Delta
  class DestroyState < AbstractState
    # Do not sanitize, keep all attributes.
    def results
      [{}, doc.attributes]
    end
  end
end
