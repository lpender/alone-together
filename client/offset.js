this.offsetBias = 0;
var offsets = [];
var counter = 0;
var maxTimes = 40;
var beforeTime = null;

// get average
var mean = function(array) {
  var sum = 0;

  array.forEach(function (value) {
    sum += value;
  });

  return sum/array.length;
}

var getTimeDiff = function() {
  beforeTime = Date.now();
  $.ajax('/api/time', {
      type: 'GET',
      success: function(response) {
          var now, timeDiff, serverTime, offset;
          counter++;

          // Get offset
          now = Date.now();
          timeDiff = (now-beforeTime)/2;
          serverTime = response.data.time-timeDiff;
          offset = now-serverTime;

          // Push to array
          offsets.push(offset)
          if (counter < maxTimes) {
            // Repeat
            getTimeDiff();
          } else {
            offsetBias = mean(offsets.slice([20,-1]))/1000;
            $("#offset").html(offsetBias)
          }
      }
  });
}

// populate 'offsets' array and return average offsets
getTimeDiff();
setInterval(function () {
  counter=0;
  getTimeDiff();
}, 10000);
