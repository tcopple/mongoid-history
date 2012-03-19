module Mongoid
  module History
    mattr_accessor :modifier_class_name
    mattr_accessor :current_user_method
    mattr_accessor :trackable_classes

    self.trackable_classes    = {}
    self.modifier_class_name  = "User"
    self.current_user_method  = :current_user

    def self.tracker_class
      @tracker_class_name.constantize
    end

    def self.tracker_class=(klass)
      @tracker_class_name = klass.name
    end

    def self.register(model, meta)
      self.trackable_classes ||= {}
      self.trackable_classes[model.name] = meta
      meta.enable_tracking!
    end

    def self.metadata(model)
      self.trackable_classes[model.name]
    end
  end
end
