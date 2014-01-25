express = require 'express'
http = require 'http'
type = require('ottypes').json0

app = express()
app.use express.static("#{__dirname}")

server = http.createServer app

WebSocketServer = require('ws').Server
wss = new WebSocketServer {server}

repl = require('repl')
replSrv = repl.start useGlobal:yes
replSrv.context.wss = wss

wss.on 'connection', (client) ->
  console.warn 'client connected'

  # The client's state
  state =
    loc: 'inbox'
    title: 'oh hi'
    ticker: 0
    content: ''

  version = 0
  inflight = {}

  send = (msg) -> client.send JSON.stringify msg

  send {a: 'i', initial:state}

  client.on 'close', ->
    console.warn 'client went away'
  client.on 'error', (e) ->
    console.warn 'Error in websocket client: ', e.stack

  client.on 'message', (msg) ->
    msg = JSON.parse msg
    console.warn 'message from client', msg

    switch msg.a
      when 'op'
        console.warn 'op', msg

        try
          op = msg.op
          type.checkValidOp op
  
          v = msg.v
          while v < version
            other = inflight[v]
            if !other?
              console.error "Could not find server op #{op.v}"
              break

            op = type.transform op, other, 'right'
            v++

          state = type.apply state, op
          send {a:'ack', v:version} # ack
          version++
        catch e
          console.error 'Could not absorb op frmo client', op, e

      when 'ack'
        delete inflight[msg.v]

  submit = (op) ->
    type.checkValidOp op
    state = type.apply state, op
    inflight[version] = op

    send {a:'op', v:version, op}
    #v = version
    version++

    #setTimeout ->
    #  send {a:'op', v:v, op}
    #, 5000

  timer = setInterval ->
    submit [
      {p:['ticker'], na:1}
      {p:['content'], od:state.content, oi:"Some <b>html</b> #{Math.random()}"}
    ]
  , 1000

  replSrv.context.client = client
  replSrv.context.submit = submit
  replSrv.context.state = state
  replSrv.context.version = version
  replSrv.context.inflight = inflight
  replSrv.context.send = send


port = 8222
server.listen port
console.warn "Listening on port #{port}\n"

replSrv.once 'exit', -> server.close()

