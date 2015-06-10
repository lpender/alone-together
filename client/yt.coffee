@onYouTubeIframeAPIReady = () ->
  new YT.Player("player",
    height: "400",
    width: "600",
    videoId: "LdH1hSWGFGU",
    events:
      onReady: (event) ->
        console.log("ready")
        # event.target.playVideo();
      ,
      onStateChange: Meteor.bindEnvironment (event) ->
        currentTime = event.target.getCurrentTime()
        if Meteor.user()
          Meteor.call("updateTime", { state: event.data, ytTime: currentTime, dateTime: new Date().getTime() })
  )

YT.load()
