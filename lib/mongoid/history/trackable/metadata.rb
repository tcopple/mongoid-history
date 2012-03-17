module Mongoid::History::Trackable
  # This is more like a facade ... ?
  class Metadata
    DEFAULT_OPTIONS = {
      :on             =>  :all,
      :except         =>  [:created_at, :updated_at],
      :modifier_field =>  :modifier,
      :version_field  =>  :version,
      :track_create   =>  false,
      :track_update   =>  true,
      :track_destroy  =>  false,
    }

    attr_reader :klass, :options

    def initialize(klass, opts={})
      @klass    = klass
      @options  = DEFAULT_OPTIONS.merge opts
    end

    def normalize_fields(*fields)
      fields.flatten.unique.compact.map(&:to_sym)
    end

    def except_fields
      @except_fields ||= normalize_fields(
        options[:except],   # user configured or default except fields
        version_field,      # contains current version
        modifier_id_field,  # contains the last modifier who is responsible for the change
        :_id,               # unique id
        :id                 # not sure if this is needed, but just in case...
      )
    end

    def only_fields
      @only_fields ||= normalize_fields(
        options[:only],
        options[:on]
      )
    end

    def track_all_fields?
      @track_all_fields ||= only_fields.include?(:all)
    end

    def version_field
      @version_field ||= options[:version_field].to_sym
    end

    def modifier_field
      @modifier_field ||= options[:modifier_field].to_sym
    end

    def modifier_class_name
      Mongoid::History.modifier_class_name
    end

    def modifier_id_field
      @modifier_id_field ||= "#{modifier_field}_id".to_sym
    end

    def scope
      @scope ||= @options[:scope] || model_name
    end

    def model_name
      klass.name.tableize.singularize.to_sym
    end

    def tracker
      Mongoid::History.tracker_class
    end

    def tracking?
      Thread.current[track_name]
    end

    def tracking=(v)
      Thread.current[track_name] = !!v
    end

    def enable_tracking!
      tracking = true
    end

    def disable_tracking!
      tracking = false
    end

    def track_name
      "mongoid_history_#{model_name}_trackable_enabled".to_sym
    end

    def disable(&block)
      begin
        disable_tracking!
        yield
      ensure
        enable_tracking!
      end
    end
  end
end
