module Mongoid::History::Trackable
  class Proxy
    attr_accessor :doc, :association_chain

    def initialize(doc)
      @doc = doc
    end

    def history_delta
      @history_delta ||= Mongoid::History::Delta.new(doc)
    end

    def association_chain
      @association_chain ||= Mongoid::History::Association::Chain.build_from_doc(doc)
    end

    def meta
      @meta ||= Mongoid::History.metadata(doc.class)
    end

    def doc_version
      doc.send(meta.version_field) || 0
    end

    def increment_doc_version
      doc.send "#{meta.version_field}=", doc_version + 1
    end

    def track?(action)
      return meta.track?(action) if action != :update
      meta.track?(action) && doc.changed?
    end

    def track!(action)
      return unless track?(action)
      increment_doc_version
      attributes = tracker_attributes(action)
      meta.tracker.create!(attributes) if attributes
    end

    def tracker_attributes(action)
      original, modified = history_delta.on(action).results

      return if original.blank? && modified.blank?

      {
        :association_chain  => association_chain,
        :scope              => meta.scope,
        :original           => original,
        :modified           => modified,
        :modifier           => doc.send(meta.modifier_field),
        :version            => doc_version,
        :action             => action
      }
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
