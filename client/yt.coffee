Meteor.startup ()->
  justSwitched = false
  thresholdSec = 0.1
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
      videoId: "bX1hsVwZ7GU",
      events:
        onReady: (player) ->
          Songs.find().observe(
            changed: (data, oldDoc) ->
              if data.videoId != oldDoc.videoId
                player.target.loadVideoById(data.videoId)
              else
                console.log(
                  event: "changed",
                  state: ytStates[data.state]
                  ytTime: data.ytTimeSec,
                )

                if ytStates[data.state] == 'PLAYING'
                  receivedPlayData = data
                  player.target.playVideo()

                else
                  receivedPlayData = null
                  player.target.pauseVideo()
            )
        ,
        onStateChange: (event) ->
          console.log(PlayerState: ytStates[event.data])

          if ytStates[event.data] == 'PLAYING' && receivedPlayData != null
            setTimeout ->
              biasSec = (Date.now() - receivedPlayData.dateTimeMs)/1000
              currentTimeSec = receivedPlayData.ytTimeSec
              desiredTimeSec = currentTimeSec + biasSec + offsetBiasMs
              actualTimeSec = event.target.getCurrentTime()
              diffSec = actualTimeSec - desiredTimeSec

              if Math.abs(diffSec) > thresholdSec
                event.target.seekTo(desiredTimeSec, true)

              $("#bias").html(biasSec)
              $("#diff").html(diffSec)
            , 10
            # receivedPlayData = null

          else if ytStates[event.data] == 'PLAYING' || ytStates[event.data] == 'PAUSED'
            dateTimeMs = Date.now()
            ytTimeSec = event.target.getCurrentTime()

            console.log(
              event: "stateChange",
              state: ytStates[event.data]
              ytTimeSec: ytTimeSec,
            )

            unless justSwitched
              Meteor.call("updateTime", {state: event.data, ytTimeSec: ytTimeSec, dateTimeMs: dateTimeMs - offsetBiasMs})

            justSwitched = true
            setTimeout ->
              justSwitched = false
            , 500

    )

  YT.load()
