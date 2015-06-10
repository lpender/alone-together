if Meteor.isClient
  Meteor.subscribe("songs")

Meteor.startup ()->
  console.log "started"

Meteor.methods(
  updateTime: (data) ->
    debugger
    song = Songs.update({}, {$set: data})
  listenForTime: () ->
    Songs.find().observe(
      changed: (newDoc, oldDoc) ->
        console.log newDoc, oldDoc
    )
)
