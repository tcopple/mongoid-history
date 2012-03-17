module Mongoid
  module History
    mattr_accessor :tracker_class_name
    mattr_accessor :modifier_class_name
    mattr_accessor :current_user_method
    mattr_accessor :trackable_classes

    self.trackable_classes    = {}
    self.modifier_class_name  = "User"
    self.current_user_method  = :current_user

    def self.tracker_class
      @tracker_class ||= tracker_class_name.to_s.classify.constantize
    end

    def self.register(model_name, meta)
      self.trackable_classes ||= {}
      self.trackable_classes[model_name] = meta
      meta.enable_tracking!
    end

    def self.metadata(model_name)
      self.trackable_classes[model_name]
    end
  end
end
