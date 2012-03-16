module Mongoid::History::Trackable
  class Visitor
    include Helper
    delegate  :only_fields,
              :except_fields,
              :track_all_fields?,
              :version_field,
              :modifier_field,
              :modifier_class_name,
              :modifier_id_field,
              :scope,
              :model_name,
              :tracker,
              :tracking?,
              :enable_tracking!,
              :disable_tracking!,
              :disable,
              :to => :metadata

    attr_accessor :doc

    def initialize(doc)
      @doc = doc
    end

    def can_track?(action)
      return tracking? unless action.to_s == "update"

      tracking? && modified_attributes_for_update.blank?
    end

    def visit_tracking!(action)
      return unless can_track?(action)

      increment_doc_version
      attributes = tracker_attributes(:create).merge(
        :version => doc_version,

        :action => action
      )
      tracker.create!(attributes)
    end

    def visit_undo!

    end

    def visit_redo!

    end

    #private

    def metadata
      @meta ||= Mongoid::History.metadata(doc.class.name)
    end

    def history
      tracker.where(:scope => scope, :association_chain => association_hash(self))
    end

    def doc_version
      doc.send(meta.version_field || 0)
    end

    def increment_doc_version
      doc.send "#{meta.version_field}=", doc_version+1
    end

    def tracker_attributes(method)
      changes = send "modified_attributes_for_#{method}"
      original, modified = transform_changes(changes)

      {
        :association_chain  => association_chain(doc),
        :scope              => scope,
        :modifier           => doc.send modifier_field,
        :original           => original,
        :modified           => modified
      }
    end

    def delta_changes(changes)
      original = {}
      modified = {}
      changes.each_pair do |k, v|
        o, m = v
        original[k] = o unless o.nil?
        modified[k] = m unless m.nil?
      end

      original.easy_diff modified
    end

    def modified_attributes_for_update
      sanitize doc.changes
    end

    def modified_attributes_for_create
      sanitize changes_for_create_or_destroy
    end

    def modified_attributes_for_destroy
      # do not sanitize, just in case we want to revert
      changes_for_create_or_destroy
    end

    # generate reliable change hash
    # mongoid #create and #destroy doesn't seem to generate
    # all the time. with ActiveModel::Dirty
    # we want to use this instead of doc.changes
    # during doc creation and destruction.
    # For lack of a better description, thus this name...
    def changes_for_create_or_destroy
      a = doc.attributes
      Hash[ [a.keys, a.values.map{|v|[nil,v]}].transpose ]
    end

    # Runs changes hash trough filters to exclude untracked fields
    def sanitize(changes)
      if track_all_fields?
        changes.reject{ |k, v| except_fields.include?(k) }
      else
        changes.reject{ |k, v| !only_fields.include?(k)  }
      end
    end
  end
end
