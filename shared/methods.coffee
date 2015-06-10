if Meteor.isClient
  Meteor.subscribe("songs")

Meteor.startup ()->
  console.log "started"

Meteor.methods(
  updateTime: (data) ->
    song = Songs.update({}, {$set: data})
  listenForTime: () ->
    debugger
    Songs.find().observe(
      changed: (newDoc, oldDoc) ->
        console.log newDoc, oldDoc
    )
)
