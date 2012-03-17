module Mongoid::History
  class Trackable
    module InstanceMethods
      #  undo :from => 1, :to => 5
      #  undo 4
      #  undo :last => 10
      def undo!(modifier, options_or_version=nil)
        versions = get_versions_criteria(options_or_version).to_a
        versions.sort!{|v1, v2| v2.version <=> v1.version}

        versions.each do |v|
          undo_attr = v.undo_attr(modifier)
          self.attributes = v.undo_attr(modifier)
        end
        save!
      end

      def redo!(modifier, options_or_version=nil)
        versions = get_versions_criteria(options_or_version).to_a
        versions.sort!{|v1, v2| v1.version <=> v2.version}

        versions.each do |v|
          redo_attr = v.redo_attr(modifier)
          self.attributes = redo_attr
        end
        save!
      end

    private
      def get_versions_criteria(options_or_version)
        if options_or_version.is_a? Hash
          options = options_or_version
          if options[:from] && options[:to]
            lower = options[:from] >= options[:to] ? options[:to] : options[:from]
            upper = options[:from] <  options[:to] ? options[:to] : options[:from]
            versions = history_tracks.where( :version.in => (lower .. upper).to_a )
          elsif options[:last]
            versions = history_tracks.limit( options[:last] )
          else
            raise "Invalid options, please specify (:from / :to) keys or :last key."
          end
        else
          options_or_version = options_or_version.to_a if options_or_version.is_a?(Range)
          version_field_name = history_trackable_options[:version_field]
          version = options_or_version || self.attributes[version_field_name] || self.attributes[version_field_name.to_s]
          version = [ version ].flatten
          versions = history_tracks.where(:version.in => version)
        end
        versions.desc(:version)
      end
    end
  end
end
