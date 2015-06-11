_this = @

Meteor.startup ()->
  timesState = 0
  timesChanged = 0
  currentPlayerState = null
  _this.offset = 0.25

  @onYouTubeIframeAPIReady = () ->
    _this.ytplayer = new YT.Player("player",
      height: "400",
      width: "600",
      videoId: "Nb3okem4OCk",
      events:
        onReady: (player) ->
          console.log("ready")
          Songs.find().observe(
            changed: (data, oldDoc) ->

              unless $("#isMaster").is(":checked")
                console.log(
                  event: "changed",
                  # isSlave: isSlave
                  state: data.state
                  timesState: timesState,
                  timesChanged: timesChanged,
                  ytTime: data.ytTime,
                  currentPlayerState: currentPlayerState,
                )

                if data.state == 1
                  player.target.playVideo()
                  diff = (new Date().getTime() - data.dateTime)/1000
                  startTime = data.ytTime + diff + offset
                  player.target.seekTo(startTime, true)
                  $("#bias").html(diff)
                else
                  player.target.pauseVideo()
            )
        ,
        onStateChange: (event) ->
          currentPlayerState = event.data

          if event.data == 1 || event.data == 2
            timesState++
            dateTime = new Date().getTime()
            ytTime = event.target.getCurrentTime()

            if $("#isMaster").is(":checked")
              console.log(
                event: "stateChange",
                # isMaster: isMaster
                state: event.data
                timesState: timesState,
                timesChanged: timesChanged,
                ytTime: ytTime,
              )

              Meteor.call("updateTime", { state: event.data, ytTime: ytTime, dateTime: dateTime })
    )

  YT.load()
