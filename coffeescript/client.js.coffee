$(document).ready ->
  connection = new WebSocket('ws://localhost:8080')

  connection.onopen = ->
    connection.send('Ping')

  connection.onerror = (error) ->
    console.log('WebSocket Error ' + error)

  connection.onmessage = (e) ->
    tweet = JSON.parse(e.data)
    $('#tweets').prepend ich.tweet(tweet) if tweet.type == "tweet"
    # $('.background:nth-child(5)').delete()
    $('#backgrounds').prepend ich.background(tweet) if tweet.type == "background"
    console.log(tweet) if tweet.type == "tweet"
    # $('.background:nth-child(5)').delete()

