Meteor.startup ()->
  justSwitched = false
  thresholdSec = 0.3
  syncData = null
  _this = @
  ytStates = [
    'ENDED',
    'PLAYING',
    'PAUSED',
    'BUFFERING',
    'CUED'
  ]

  onPlayerPlay = (player, state) ->
    masterNowMs = Date.now()
    ytTimeSec = player.getCurrentTime()

    console.log(event: 'onPlayerPlay', state: ytStates[state], ytTimeSec: ytTimeSec)
    Meteor.call('updateTime', {state: state, ytTimeSec: ytTimeSec, masterNowMs: masterNowMs, masterOffsetMs: localOffsetMs})

  onPlayerPause = (player, state) ->
    console.log(event: 'onPlayerPause', state: ytStates[state])
    Meteor.call('updateState', {state: state})

  syncPlayer = (player, syncData) ->
    console.log(event: 'syncPlayer', syncData: syncData)

    masterYtTimeSec = syncData.ytTimeSec
    actualYtTimeSec = player.getCurrentTime()

    serverNowSentMs = syncData.masterNowMs #+ receivedPlayData.masterOffsetMs
    serverNowReceivedMs = Date.now() #+ localOffsetMs;

    latencySec = (serverNowReceivedMs - serverNowSentMs)/1000
    desiredYtTimeSec = masterYtTimeSec + latencySec
    ytTimeDiffSec = actualYtTimeSec - desiredYtTimeSec

    if Math.abs(ytTimeDiffSec) > $('#syncThreshold').val()
      player.seekTo(desiredYtTimeSec, true)
    else
      syncData = null

    $("#latency").html(latencySec)
    $("#ytTimeDiff").html(ytTimeDiffSec)

  @onYouTubeIframeAPIReady = () ->
    _this.ytPlayer = new YT.Player("player",
      height: "400",
      width: "600",
      videoId: "bX1hsVwZ7GU",
      events:
        onStateChange: (event) ->
          if ytStates[event.data] == 'PLAYING'
            if syncData != null
              syncPlayer(event.target, syncData)
            else
              onPlayerPlay(event.target, event.data)
          else if ytStates[event.data] == 'PAUSED'
            onPlayerPause(event.target, event.data)
        ,
        onReady: (player) ->
          Songs.find().observe(
            changed: (newSong, oldSong) ->
              if newSong.videoId != oldSong.videoId
                player.target.loadVideoById(newSong.videoId)
              else
                console.log(event: 'songChanged', state: ytStates[newSong.state], ytTimeSec: newSong.ytTimeSec)

                if ytStates[newSong.state] == 'PLAYING'
                  syncData = newSong
                  player.target.playVideo()
                else
                  syncData = null
                  player.target.pauseVideo()
          )
    )

  YT.load()
