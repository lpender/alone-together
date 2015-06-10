@onYouTubeIframeAPIReady = () ->
  new YT.Player("player",
    height: "400",
    width: "600",
    videoId: "LdH1hSWGFGU",
    events:
      onReady: () ->
        console.log("ready")
        if Meteor.user()
          console.log("user found")
        else
          console.log "no user"
          Songs.find().observe(
            changed: (data, oldDoc) ->
              console.log data
              if data.state == 1
                currentTime = new Date().getTime()
                timeDifferenceInMs = data.currentTime - currentTime
                debugger
          )
          # Meteor.call("listenForTime")
        # if Meteor.user() != null
          # Meteor.call("listenForTime")
        # event.target.playVideo();
      ,
      onStateChange: Meteor.bindEnvironment (event) ->
        currentTime = event.target.getCurrentTime()
        if Meteor.user()
          Meteor.call("updateTime", { state: event.data, ytTime: currentTime, dateTime: new Date().getTime() })
  )

YT.load()
