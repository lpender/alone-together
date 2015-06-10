if Songs.find().count() == 0
  Songs.insert(
    title: 'Song',
    state: 'stopped',
    ytTime: 0,
    dateTime: 0
  )
