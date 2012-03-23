module Mongoid::History::Operation
  class Undo < Redo
    def build_attributes(track)
      Mongoid::History::Builder::UndoAttributes.new(doc).build(track)
    end

    def build_tracks(version)
      super.invert
    end
  end
end
