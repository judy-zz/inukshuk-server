connection = new WebSocket('ws://localhost:8080')

connection.onopen = ->
  connection.send('Ping')

connection.onerror = (error) ->
  console.log('WebSocket Error ' + error)

connection.onmessage = (e) ->
  console.log('Server: ' + e.data)

