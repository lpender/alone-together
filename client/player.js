Template.body.events({
  'submit .new-song': function(event) {
    var song = event.target.song.value;

    Meteor.http.get(
      "https://www.googleapis.com/youtube/v3/search",
      {
        params: {
          key: "AIzaSyDLrIeDe9tWYc3MLuqBLYOykl-lu9bmE74",
          part: "snippet",
          type: "video",
          q: song
        }
      },

      function (error, result) {
        var songId = result.data.items[0].id.videoId;

        Meteor.call("updateVideoId", songId)
      }
    );

    event.target.song.value = "";

    return false;
  }
});
