module Mongoid::History::Operation
  class Redo < Operation
    def build_tracks(versions)
      Mongoid::History::Builder::TrackQuery.new(doc).build(versions)
    end

    def build_attributes(track)
      Mongoid::History::Builder::RedoAttributes.new(doc).build(track)
    end

    def attributes(tracks)
      tracks.inject({}) do |attributes, track|
        attributes.merge! build_attributes(track)
      end
    end

    def execute!(modifier, versions)
      tracks          = build_tracks(versions)
      doc.attributes  = attributes(tracks)
      doc.send("#{meta.modifier_field}=", modifier)
      doc.save!
    end
  end
end

#################################################################
# Single Undo: doc could be destroyed or new
#
# if track is marked destroyed
#   do nothing if doc is destroyed or doc is new
#   create new doc with modified attributes from track.
#
# if track is marked created
#   do nothing if doc is destroyed or doc is new
#   undo create. ( destroy doc, if not already destroyed )
#
# if track is marked updated
#   Raise error if doc is destroyed or doc is new
#   build attributes & save
#
##################################################################
# Single Redo: doc could be destroyed  or new
#
# if track is marked destroyed
#   do nothing if doc is destroyed or doc is new
#   destroy doc
#
# if track is marked created
#   create doc if doc is destroyed or doc is new
#   do nothing
#
# if track is marked updated
#   raise error if doc is destroyed or doc is new
#   build attributes & save
#

# Multi Undo
#
# doc state:
#   persisted
#   unpersisted
#
# doc actions:
#   create
#   delete
#   update
#
#                create
#             <-----------
#  persisted               unpersisted
#   | /\      ----------->
#   |--|         delete
#    update
#
#
###############################################################
# Multi Redo
#
# doc state:
#   persisted
#   unpersisted
#
# doc actions:
#   create
#   delete
#   update
#
#                create
#             <-----------
#  persisted               unpersisted
#    | |      ----------->
#    |-|         delete
#    update
#
###################################################################
# Multi Undo: doc could be destroyed or new
# if doc is new
#   raise error
#
# if doc is destroyed or nil
#   raise error if tracks.first is not destroyed
#
# else
#   destroy doc if tracks.last is created
#   for each track in tracks
#     merge attribute if track is modified
#     do nothing if track is
#
#
# if track is marked destroyed
#   do nothing if doc is destroyed or doc is new
#   create new doc with modified attributes from track.
#
# if track is marked created
#   do nothing if doc is destroyed or doc is new
#   undo create. ( destroy doc, if not already destroyed )
#
# if track is marked updated
#   Raise error if doc is destroyed or doc is new
#   build attributes & save
#
###################################################################
# Multi Redo: doc could be destroyed  or new
#
# if track is marked destroyed
#   do nothing if doc is destroyed or doc is new
#   destroy doc
#
# if track is marked created
#   create doc if doc is destroyed or doc is new
#   do nothing
#
# if track is marked updated
#   raise error if doc is destroyed or doc is new
#   build attributes & save
#
