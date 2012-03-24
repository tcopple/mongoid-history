module Mongoid::History::Operation
  class Undo < Redo
    def build_attributes
      @attributes.merge! Mongoid::History::Builder::UndoAttributes.new(doc).build(@current_track)
    end

    def build_tracks(version)
      super.reverse
    end

    def commit!
      case current_action
      when :create
        re_destroy!
      when :destroy
        re_create!
      else
        update!
      end
    end
  end
end
