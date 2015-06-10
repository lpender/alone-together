Meteor.startup () ->
  Meteor.publish("songs", ()->
    Songs.find({})
  )
