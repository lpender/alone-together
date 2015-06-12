if Songs.find().count() == 0
  Songs.insert(
    title: 'Song',
    state: 'stopped',
    ytTimeSec: 0,
    dateTimeMs: 0
  )
