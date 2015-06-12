this.offsetBiasMs = 0;
var offsets = [];
var counter = 0;
var maxTimes = 40;
var beforeTimeMs = null;

// get average
var mean = function(values) {
  return _.reduce(values, function (sum, value) {
      return sum + value;
  }, 0) / values.length;
};

var getTimeDiff = function() {
  beforeTimeMs = Date.now();
  $.ajax('/api/time', {
      type: 'GET',
      success: function(response) {
          var nowMs, timeDiffMs, serverTimeMs, offsetMs;
          counter++;

          // Get offset
          nowMs = Date.now();
          timeDiffMs = (nowMs-beforeTimeMs)/2;
          serverTimeMs = response.data.time-timeDiffMs;
          offsetMs = nowMs-serverTimeMs;

          // Push to array
          offsets.push(offsetMs);
          if (counter < maxTimes) {
            // Repeat
            getTimeDiff();
          } else {
            offsetBiasMs = mean(offsets.slice([20,-1]))/1000;
            $("#offset").html(offsetBiasMs)
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
