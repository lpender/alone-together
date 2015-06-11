Meteor.startup ()->
  timesState = 0
  timesChanged = 0
  offset = if navigator.userAgent.match(/(iPad|iPhone|iPod)/g) then 0.25 else 0

  @onYouTubeIframeAPIReady = () ->
    new YT.Player("player",
      height: "400",
      width: "600",
      videoId: "bX1hsVwZ7GU",
      events:
        onReady: (player) ->
          console.log("ready")
          Songs.find().observe(
            changed: (data, oldDoc) ->
              timesChanged++
              isSlave = timesChanged > timesState

              console.log(
                event: "changed",
                state: data.state
                timesState: timesState,
                timesChanged: timesChanged,
                isSlave: isSlave
              )

              if isSlave
                if data.state == 1
                  timesChanged++
                  player.target.playVideo()
                  setTimeout ->
                    diff = (new Date().getTime() - data.dateTime)/1000
                    startTime = data.ytTime + diff + offset
                    player.target.seekTo(startTime, true)
                    $("#bias").html(diff)
                  , 1000
                else
                  player.target.pauseVideo()
            )
        ,
        onStateChange: (event) ->
          timesState++
          isMaster = timesState > timesChanged

          console.log(
            event: "stateChange",
            state: event.data
            timesState: timesState,
            timesChanged: timesChanged,
            isMaster: isMaster
          )

          if isMaster
            dateTime = new Date().getTime()
            currentTime = event.target.getCurrentTime()

            Meteor.call("updateTime", { state: event.data, ytTime: currentTime, dateTime: dateTime })
    )

  YT.load()
