express = require 'express'
http = require 'http'
{json0} = require 'ottypes'

app = express()
app.use express.static("#{__dirname}")

server = http.createServer app

WebSocketServer = require('ws').Server
wss = new WebSocketServer {server}

wss.on 'connection', (client) ->
  console.log 'client connected'
  # The client's state
  state =
    loc: 'inbox'
    title: 'oh hi'

  send = (msg) -> client.send JSON.stringify msg

  send
    a: 'i'
    initial: state

  client.on 'close', ->
    console.log 'client went away'
  client.on 'error', (e) ->
    console.log 'Error in websocket client: ', e.stack

  client.on 'message', (msg) ->
    msg = JSON.parse msg
    console.log 'message from client', msg

    switch msg.a
      when 'op'
        console.log 'op', msg
        send {a:'ack'} # ack
    


port = 8222
server.listen port
console.log "Listening on port #{port}"

