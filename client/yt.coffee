Meteor.startup ()->
  justSwitched = false
  threshold = 0.1
  receivedPlayData = null
  _this = @
  ytStates = [
    'ENDED',
    'PLAYING',
    'PAUSED',
    'BUFFERING',
    'CUED'
  ]

  @onYouTubeIframeAPIReady = () ->
    _this.ytPlayer = new YT.Player("player",
      height: "400",
      width: "600",
      videoId: "XpIrFglZfQU",
      events:
        onReady: (player) ->
          Songs.find().observe(
            changed: (data, oldDoc) ->
              if data.videoId != oldDoc.videoId
                player.target.loadVideoById(data.videoId)
              else
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
          console.log(PlayerState: ytStates[event.data])

          if event.data == 1 && receivedPlayData != null
            setTimeout ->
              bias = (Date.now() - receivedPlayData.dateTime)/1000
              currentTime = receivedPlayData.ytTime
              desiredTime = currentTime + bias + offsetBias
              actualTime = event.target.getCurrentTime()
              diff = actualTime - desiredTime

              if Math.abs(diff) > threshold
                event.target.seekTo(desiredTime, true)

              $("#bias").html(bias)
              $("#diff").html(diff)
            , 10
            # receivedPlayData = null

          else if event.data == 1 || event.data == 2
            dateTime = Date.now()
            ytTime = event.target.getCurrentTime()

            console.log(
              event: "stateChange",
              state: event.data
              ytTime: ytTime,
            )

            unless justSwitched
              Meteor.call("updateTime", { state: event.data, ytTime: ytTime, dateTime: dateTime - offsetBias})

            justSwitched = true
            setTimeout ->
              justSwitched = false
            , 500

    )

  YT.load()
