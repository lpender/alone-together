Meteor.startup ()->
  _this = @
  justSwitched = false
  playInterval = null
  syncData = null
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
    masterNowMs = Date.now()
    ytTimeSec = player.getCurrentTime()

    console.log(event: 'onMasterPlay', state: ytStates[state], ytTimeSec: ytTimeSec)
    Meteor.call('updateTime', {state: state, ytTimeSec: ytTimeSec, masterNowMs: masterNowMs, masterOffsetMs: localOffsetMs})

  onMasterPlay = (player, state) ->
    clearInterval(playInterval)
    playFunction(player, state)
    playInterval = setInterval ->
      playFunction(player, state)
    , 5000

  onMasterPause = (player, state) ->
    console.log(event: 'onMasterPause', state: ytStates[state])
    clearInterval(playInterval)
    Meteor.call('updateState', {state: state})

  syncPlayer = (player, syncData) ->
    console.log(event: 'syncPlayer', syncData: syncData)

    masterYtTimeSec = syncData.ytTimeSec
    actualYtTimeSec = player.getCurrentTime()

    serverNowSentMs = syncData.masterNowMs #+ syncData.masterOffsetMs
    serverNowReceivedMs = Date.now() #+ localOffsetMs

    latencySec = (serverNowReceivedMs - serverNowSentMs)/1000
    desiredYtTimeSec = masterYtTimeSec + latencySec
    ytTimeDiffSec = actualYtTimeSec - desiredYtTimeSec

    if Math.abs(ytTimeDiffSec) > $('#syncThreshold').val()
      player.seekTo(desiredYtTimeSec, true)

    syncData = null

    $("#latency").html(latencySec)
    $("#ytTimeDiff").html(ytTimeDiffSec)


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
