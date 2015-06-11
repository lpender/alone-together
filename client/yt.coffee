_this = @

Meteor.startup ()->
  timesState = 0
  timesChanged = 0
  _this.offset = 0.25
  receivedPlayData = null

  @onYouTubeIframeAPIReady = () ->
    _this.ytplayer = new YT.Player("player",
      height: "400",
      width: "600",
      videoId: "bX1hsVwZ7GU",
      events:
        onReady: (player) ->
          Songs.find().observe(
            changed: (data, oldDoc) ->

              unless $("#isMaster").is(":checked")
                console.log(
                  event: "changed",
                  state: data.state
                  ytTime: data.ytTime,
                )

                if data.state == 1
                  receivedPlayData = data
                  player.target.playVideo()

                else
                  receivedPlayData = null
                  player.target.pauseVideo()
            )
        ,
        onStateChange: (event) ->
          if event.data == 1 || event.data == 2

            if event.data == 1 && receivedPlayData != null
              diff = (new Date().getTime() - receivedPlayData.dateTime)/1000
              startTime = receivedPlayData.ytTime + diff + offset
              event.target.seekTo(startTime, true)
              $("#bias").html(diff)
              receivedPlayData = null

            dateTime = new Date().getTime()
            ytTime = event.target.getCurrentTime()

            if $("#isMaster").is(":checked")
              console.log(
                event: "stateChange",
                state: event.data
                ytTime: ytTime,
              )

              Meteor.call("updateTime", { state: event.data, ytTime: ytTime, dateTime: dateTime })
    )

  YT.load()
