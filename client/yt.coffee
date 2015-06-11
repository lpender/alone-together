Meteor.startup ()->
  offset = 0
  timesState = 0
  timesChanged = 0
  receivedPlayData = null
  lastBuff = null

  @onYouTubeIframeAPIReady = () ->
    new YT.Player("player",
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
          console.log(event.data)

          if $("#isMaster").is(":checked")
            if event.data == 1 || event.data == 2
              dateTime = Date.now()
              ytTime = event.target.getCurrentTime()

              console.log(
                event: "stateChange",
                state: event.data
                ytTime: ytTime,
              )

              Meteor.call("updateTime", { state: event.data, ytTime: ytTime, dateTime: dateTime })

          else
            if event.data == 3
              if lastBuff == null
                lastBuff = Date.now()
              return

            if event.data == 1
              if lastBuff != null
                offset = (Date.now() - lastBuff)/1000
                console.log "offset:"+offset
              else
                offset = 0
              if receivedPlayData != null
                diff = (Date.now() - receivedPlayData.dateTime)/1000
                currentTime = receivedPlayData.ytTime
                $("#bias").html(diff)
                startTime = currentTime + diff + offset
                event.target.seekTo(startTime, true)
                receivedPlayData = null
              lastBuff = null
    )

  YT.load()
