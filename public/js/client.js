(function() {

  $(document).ready(function() {
    var connection;
    connection = new WebSocket('ws://localhost:7000');
    connection.onopen = function() {
      return true;
    };
    connection.onerror = function(error) {
      return console.log('WebSocket Error ' + error);
    };
    return connection.onmessage = function(e) {
      var tweet;
      tweet = JSON.parse(e.data);
      if (tweet.type === "tweet") $('#tweets').prepend(ich.tweet(tweet));
      if (tweet.type === "background") {
        $('#backgrounds').prepend(ich.background(tweet));
      }
      if (tweet.type === "tweet") return console.log(tweet);
    };
  });

}).call(this);
