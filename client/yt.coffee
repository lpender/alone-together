Meteor.startup ()->
  _this = @
  playInterval = null
  syncData = null
  timesSynced = 0
  ytStates = [
    'ENDED',
    'PLAYING',
    'PAUSED',
    'BUFFERING',
    'CUED'
  ]

  isMaster = ->
    $("#isMaster").is(":checked")

  playFunction = (player,state) ->

  onMasterPlay = (player, state) ->
    console.log(event: 'onMasterPlay', state: ytStates[state], ytTimeSec: ytTimeSec)

    # Find local clock and playhead time, so they can be correlated.
    localNowMs = Date.now()
    ytTimeSec = player.getCurrentTime()

    # Update db
    Meteor.call('updateTime', {
      state: state,
      ytTimeSec: ytTimeSec,
      masterNowMs: localNowMs
      masterOffsetMs: localOffsetMs
    })

  onMasterPause = (player, state) ->
    console.log(event: 'onMasterPause', state: ytStates[state])

    # Update db
    Meteor.call('updateState', {state: state})

  syncPlayer = (player, syncData) ->
    console.log(event: 'syncPlayer', syncData: syncData, localOffsetMs: localOffsetMs)

    timesSynced++

    # Get YouTube seek times
    masterYtTimeSec = syncData.ytTimeSec
    currentYtTimeSec = player.getCurrentTime()

    # Get universal sent/received clock times
    universalPlaySentMs = syncData.masterNowMs + syncData.masterOffsetMs
    universalPlayRecdMs = Date.now() + localOffsetMs

    # Use universal times to compute the latency
    latencySec = (universalPlayRecdMs - universalPlaySentMs)/1000

    # Offset requested seek time with latency
    desiredYtTimeSec = masterYtTimeSec + latencySec

    # Check offset between seek and playhead
    diffYtTimeSec = currentYtTimeSec - desiredYtTimeSec

    # If it's outside of the allowed threshold, seek again
    if Math.abs(diffYtTimeSec) > $('#syncThreshold').val() && timesSynced < 50
      player.mute()
      player.seekTo(desiredYtTimeSec, true)
    else
      player.unMute()
      timesSynced = 0

    # Good housekeeping
    syncData = null

    # Display
    $("#latency").html(latencySec)
    $("#ytTimeDiff").html(diffYtTimeSec)


  @onYouTubeIframeAPIReady = () ->
    _this.ytPlayer = new YT.Player("player",
      height: "400",
      width: "600",
      videoId: "",
      events:
        onStateChange: (event) ->
          if isMaster()
            if ytStates[event.data] == 'PLAYING'
              onMasterPlay(event.target, event.data)
            else if ytStates[event.data] == 'PAUSED'
              onMasterPause(event.target, event.data)
          else if syncData != null && ytStates[event.data] == "PLAYING"
            syncPlayer(event.target, syncData)
        ,
        onReady: (player) ->
          Songs.find().observe(
            added: (song) ->
              if song.videoId
                player.target.pauseVideo()
                player.target.seekTo(0)
                player.target.cueVideoById(song.videoId)
            changed: (newSong, oldSong) ->
              if newSong.videoId != oldSong.videoId
                player.target.pauseVideo()
                player.target.seekTo(0)
                player.target.cueVideoById(newSong.videoId)
              else
                console.log(event: 'songChanged', state: ytStates[newSong.state], ytTimeSec: newSong.ytTimeSec)

                if !!!isMaster()
                  if ytStates[newSong.state] == 'PLAYING'
                    syncData = newSong
                    player.target.playVideo()
                  else
                    syncData = null
                    player.target.pauseVideo()
          )
    )

  YT.load()
