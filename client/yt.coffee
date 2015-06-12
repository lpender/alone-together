Meteor.startup ()->
  justSwitched = false
  syncData = null
  _this = @
  ytStates = [
    'ENDED',
    'PLAYING',
    'PAUSED',
    'BUFFERING',
    'CUED'
  ]

  isMaster = ->
    $("#isMaster").is(":checked")

  onMasterPlay = (player, state) ->
    masterNowMs = Date.now()
    ytTimeSec = player.getCurrentTime()

    console.log(event: 'onMasterPlay', state: ytStates[state], ytTimeSec: ytTimeSec)
    Meteor.call('updateTime', {state: state, ytTimeSec: ytTimeSec, masterNowMs: masterNowMs, masterOffsetMs: localOffsetMs})

  onMasterPause = (player, state) ->
    console.log(event: 'onMasterPause', state: ytStates[state])
    Meteor.call('updateState', {state: state})

  syncPlayer = (player, syncData) ->
    console.log(event: 'syncPlayer', syncData: syncData)

    setTimeout ->
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
    , 10


  @onYouTubeIframeAPIReady = () ->
    _this.ytPlayer = new YT.Player("player",
      height: "400",
      width: "600",
      videoId: "bX1hsVwZ7GU",
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
            changed: (newSong, oldSong) ->
              if newSong.videoId != oldSong.videoId
                player.target.loadVideoById(newSong.videoId)
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
