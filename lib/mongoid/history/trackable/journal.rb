# extract modified and original fields
module Mongoid::History::Trackable
  class Journal
    attr_reader :doc
    delegate    :results, :to => "@current_state"

    def initialize(doc)
      @doc            = doc
      @states         = {}
      @current_state  = nil
    end

    def state_class(name)
      "Mongoid::History::Trackable::Journal::#{name.to_s.classify}".constantize
    end

    # doc.journal.on(:create).results
    def on(name)
      klass = state_class(name)
      @states[klass] ||= klass.new(doc)
      @current_state = @states[klass]
      self
    end

    # @abstract
    class State
      attr_reader :doc
      def initialize(doc)
        @doc = doc
      end

      # @abstract
      # should return [original, :modified]
      def results; end
    end

    class Create < State
      def meta
        Mongoid::History.metadata(doc.class.name)
      end

      def results
        original = {}
        modified = {}

        changes.each_pair do |k, v|
          o, m = v
          original[k] = o unless o.nil?
          modified[k] = m unless m.nil?
        end

        original, modified = original.easy_diff modified
      end

      def changes
        sanitize doc.changes
      end

      def sanitize(change_set)
        if meta.track_all_fields?
          change_set.reject{ |k, v| meta.except_fields.include?(k.to_sym) }
        else
          change_set.select{ |k, v| meta.only_fields.include?(k.to_sym)  }
        end
      end
    end

    class Update < Create; end

    class Destroy < State
      # Do not sanitize, keep all attributes.
      def results
        [ {}, doc.attributes ]
      end
    end
  end
end
