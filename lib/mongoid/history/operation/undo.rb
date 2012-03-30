module Mongoid::History::Operation
  class Undo < Redo
    def attr_builder
      Mongoid::History::Builder::UndoAttributes
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
