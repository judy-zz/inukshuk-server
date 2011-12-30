(function() {
  var connection;

  connection = new WebSocket('ws://localhost:8080');

  connection.onopen = function() {
    return connection.send('Ping');
  };

  connection.onerror = function(error) {
    return console.log('WebSocket Error ' + error);
  };

  connection.onmessage = function(e) {
    return console.log('Server: ' + e.data);
  };

}).call(this);
