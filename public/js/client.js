(function() {

  $(document).ready(function() {
    var connection;
    connection = new WebSocket('ws://localhost:8080');
    connection.onopen = function() {
      return connection.send('Ping');
    };
    connection.onerror = function(error) {
      return console.log('WebSocket Error ' + error);
    };
    return connection.onmessage = function(e) {
      var tweet;
      tweet = JSON.parse(e.data);
      console.log('Server: ' + tweet);
      return $('#tweets').prepend(ich.tweet(tweet));
    };
  });

}).call(this);
