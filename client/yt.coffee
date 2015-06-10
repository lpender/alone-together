@onYouTubeIframeAPIReady = () ->
  new YT.Player("player",
    height: "400",
    width: "600",
    videoId: "LdH1hSWGFGU",
    events:
      onReady: () ->
        console.log("ready")
        # if Meteor.user()
        #   console.log("yes")
        # else
        #   debugger
          # Meteor.call("listenForTime")
        # if Meteor.user() != null
          # Meteor.call("listenForTime")
        # event.target.playVideo();
      ,
      onStateChange: Meteor.bindEnvironment (event) ->
        console.log event
        currentTime = event.target.getCurrentTime()
        if Meteor.user()
          console.log("user")
          Meteor.call("updateTime", { state: event.data, ytTime: currentTime, dateTime: new Date().getTime() })
  )

YT.load()
