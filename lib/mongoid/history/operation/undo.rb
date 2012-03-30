module Mongoid::History::Operation
  class Undo < Redo
    def attr_builder
      Mongoid::History::Builder::UndoAttributes
    end

    def update_fsm
      case current_action
      when :create
        @fsm.destroy!
      when :destroy
        @fsm.create!
      else
        @fsm.update!
      end
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
