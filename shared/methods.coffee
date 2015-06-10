if Meteor.isClient
  Meteor.subscribe("songs")

Meteor.startup ()->
  console.log "started"

Meteor.methods(
  updateTime: (data) ->
    song = Songs.update({}, {$set: data})
)
