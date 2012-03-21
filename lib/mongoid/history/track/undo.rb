module Mongoid::History
  class AttributeBuilder
    attr_reader :doc, :track
    def initialize(doc, track)
      @doc   = doc
      @track = track
    end

    def affected
      @affected ||= (track.modified.keys | track.original.keys).inject({}) do |h,k|
        h[k] = doc ? doc.attributes[k] : track.modified[k]
        h
      end
    end
  end

  class UndoAttributeBuilder < AttributeBuilder
    def build
      affected.
        easy_unmerge(track.modified).
        easy_merge(track.original)
    end
  end

  class RedoAttributeBuilder < AttributeBuilder
    def build
      affected.
        easy_unmerge(track.original).
        easy_merge(track.modified)
    end
  end

  class VersionQuery
    attr_reader :doc
    def initialize(doc, version_arg)
      @versions = extract_versions version_arg
    end

    def meta
      @meta ||= Mongoid::History.meta(doc.class)
    end

    def query
      doc.history_tracks.where(:version.in => @versions).desc(:version)
    end

    def extract_versions(arg)
      case arg
      when Fixnum
        [ arg ]
      when Array
        arg
      when Range
        arg.to_a
      when Hash
        normalize_options arg
      end.flatten.uniq.compact
    end

    def normalize_options(opts)
      if opts[:from] && opts[:to]
        range = [ opts[:from].to_i, opts[:to].to_i ]
        min = range.min
        max = range.max
        (min..max).to_a
      elsif opts[:last]
        max = doc.send meta.version_field
        min = max - opts[:last].to_i
        min = [0, min].max
        (min..max).to_a
      else
        []
      end
    end
  end


  module Operation
    class Base
      attr_reader :doc
      def initialize(doc)
        @doc = doc
      end

      def meta
        @meta ||= Mongoid::History.meta(doc.class)
      end

      def execute!
        # @abstract
      end
    end

    class Journal < Base
      def increment_doc_version
        version = doc.send meta.version_field
        doc.send "#{meta.version_field}=", version + 1
      end

      def track?(action)
        return meta.track?(action) if action != :update
        meta.track?(action) && doc.changed?
      end

      def execute!(action)
        return unless track?(action)
        increment_doc_version

        builder = Mongoid::History::Track::Builder.new(doc, action)
        track = builder.build
        track.save! if track
      end
    end

    class UndoRedo < Base
      def initialize(doc, modifier, versions)
        super
        @modifier = modifier
        @versions = VersionQuery.new(opts[:versions]).query
      end
    end

    class Undo < UndoRedo
      def execute!
        versions.each do |v|
          doc.attributes = UndoAttributeBuilder.new(doc, v).build
        end
        doc.send("#{meta.modifier_field}=", modifier)
        doc.save!
      end
    end

    class Redo < UndoRedo
      def execute!
        versions.invert.each do |v|
          doc.attributes = RedoAttributeBuilder.new(doc, v).build
        end
        doc.send("#{meta.modifier_field}=", modifier)
        doc.save!
      end
    end
  end

end
