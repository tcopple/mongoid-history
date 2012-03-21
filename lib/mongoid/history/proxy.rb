module Mongoid::History
  class Proxy
    attr_accessor :doc, :association_chain

    def initialize(doc)
      @doc = doc
    end

    def track!(action)
      return unless track?(action)
      increment_doc_version

      builder = Mongoid::History::Track::Builder.new(doc, action)
      track = builder.build
      track.save! if track
    end

    def history
      meta.tracker.where(
        :scope              => meta.scope,
        :association_chain  => association_chain.root.to_hash
      )
    end

    def undo!(modifier, options_or_version)
      versions = get_versions_criteria(options_or_version).to_a
      versions.sort!{|v1, v2| v2.version <=> v1.version}

      versions.each do |v|
        undo_attr = v.undo_attr(modifier)
        doc.attributes = v.undo_attr(modifier)
      end
      doc.save!
    end

    def redo!(modifier, options_or_version)
      versions = get_versions_criteria(options_or_version).to_a

      # do we need this? we are already querying with descending order
      versions.sort!{|v1, v2| v1.version <=> v2.version}

      versions.each do |v|
        redo_attr = v.redo_attr(modifier)
        doc.attributes = redo_attr
      end
      doc.save!
    end

    # private methods below
    def meta
      @meta ||= Mongoid::History.meta(doc.class)
    end

    def association_chain
      @association_chain ||= Association::Chain.build_from_doc(doc)
    end

    def increment_doc_version
      version = doc.send meta.version_field
      doc.send "#{meta.version_field}=", version + 1
    end

    def track?(action)
      return meta.track?(action) if action != :update
      meta.track?(action) && doc.changed?
    end

    def get_versions_criteria(options_or_version)
      if options_or_version.is_a? Hash
        options = options_or_version
        if options[:from] && options[:to]
          lower = options[:from] >= options[:to] ? options[:to] : options[:from]
          upper = options[:from] <  options[:to] ? options[:to] : options[:from]
          versions = history.where( :version.in => (lower .. upper).to_a )
        elsif options[:last]
          versions = history.limit( options[:last] )
        else
          raise "Invalid options, please specify (:from / :to) keys or :last key."
        end
      else
        options_or_version = options_or_version.to_a if options_or_version.is_a?(Range)
        version = options_or_version || doc.send(meta.version_field)
        version = [ version ].flatten
        versions = history.where(:version.in => version)
      end
      versions.desc(:version)
    end
  end
end
