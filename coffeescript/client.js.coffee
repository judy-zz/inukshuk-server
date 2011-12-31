$(document).ready ->
  connection = new WebSocket('ws://localhost:8080')

  connection.onopen = ->
    connection.send('Ping')

  connection.onerror = (error) ->
    console.log('WebSocket Error ' + error)

  connection.onmessage = (e) ->
    tweet = JSON.parse(e.data)
    console.log('Server: ' + tweet)
    $('#tweets').prepend(ich.tweet(tweet))
    # $('.tweet:first').show("slide", { direction: "down" }, 1000)
    # $('#backgrounds').prepend(ich.background(tweet))

