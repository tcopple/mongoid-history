module Mongoid::History::Operation
  class Track < Abstract
    def build_track(action)
      Mongoid::History::Builder::Track.new(doc).build(action)
    end

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

      builder = build_track(action)
      track = builder.build
      track.save! if track
    end
  end
end
