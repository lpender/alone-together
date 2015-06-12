Meteor.startup ()->
  @offset = if navigator.userAgent.match(/(iPad|iPhone|iPod)/g) then 0.25 else 0
  threshold = 0.05
  receivedPlayData = null
  _this = @

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
          console.log(event.data)

          if event.data == 1 && receivedPlayData != null
            bias = (Date.now() - receivedPlayData.dateTime)/1000
            currentTime = receivedPlayData.ytTime
            desiredTime = currentTime + bias + offset
            actualTime = event.target.getCurrentTime()

            if Math.abs(actualTime - desiredTime) > threshold
              event.target.seekTo(desiredTime, true)

            $("#bias").html(bias)
            # receivedPlayData = null

          else if event.data == 1 || event.data == 2
            dateTime = Date.now()
            ytTime = event.target.getCurrentTime()

            console.log(
              event: "stateChange",
              state: event.data
              ytTime: ytTime,
            )

            Meteor.call("updateTime", { state: event.data, ytTime: ytTime, dateTime: dateTime })

    )

  YT.load()
