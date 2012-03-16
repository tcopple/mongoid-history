module Mongoid
  module History
    mattr_accessor :tracker_class_name
    mattr_accessor :modifier_class_name
    mattr_accessor :current_user_method
    mattr_accessor :trackable_class_metadata

    self.trackable_class_metadata = {}

    def self.tracker_class
      @tracker_class ||= tracker_class_name.to_s.classify.constantize
    end

    def self.regsiter(model_name, meta)
      self.trackable_classes ||= {}
      self.trackable_classes[model_name] = meta
      meta.track!
    end

    def self.metadata(model_name)
      self.trackable_classes[model_name]
    end
  end
end
