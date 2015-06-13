this.localOffsetMs = 0;
var offsets = [];
var counter = 0;
var maxTimes = 40;
var beforeTime = null;

// get average
this.mean = function(values) {
  return _.reduce(values, function (sum, value) {
      return sum + value;
  }, 0) / values.length;
};

var getTimeDiff = function() {
  beforeMs = Date.now();
  $.ajax('/api/time', {
      type: 'GET',
      success: function(response) {
          var now, timeDiff, serverTime, offset;
          counter++;

          // Get offset
          nowMs = Date.now(); // now
          timeDiffMs = (nowMs-beforeMs)/2; // half the round trip
          serverTimeMs = response.data.time-timeDiffMs; // calculate the serverTime
          offsetMs = nowMs-serverTimeMs; // how far ahead are we?

          // Push to array
          offsets.push(offsetMs);
          if (counter < maxTimes) {
            // Repeat
            getTimeDiff();
          } else {
            localOffsetMs = mean(offsets.slice([20,-1]));
            $("#localOffsetMs").html(localOffsetMs)
          }
      }
  });
};

// populate 'offsets' array and return average offsets
getTimeDiff();
setInterval(function () {
  counter=0;
  getTimeDiff();
}, 10000);
