

render = (state) ->
  title = document.getElementById 'title'
  title.innerText = state.title








type = ottypes.json0

ws = new WebSocket 'ws://' + window.location.host + window.location.pathname
ws.onerror = (err) ->
  console.err err

state = null
version = 0
pending = null
inflight = null

ws.onmessage = (msg) ->
  msg = JSON.parse msg.data
  console.log 'websocket msg', msg

  switch msg.a
    when 'i' # initial
      state = msg.initial
      render state

    when 'ack'
      version++
      inflight = null
      flush()

    when 'op'
      if msg.v > version
        console.warn 'Future operation !?'
        return

      op = msg.op

      [inflight, op] = type.transformX inflight, op if inflight
      [pending, op] = type.transformX pending, op if pending
      version++

      state = type.apply state, op
      render state

ws.onopen = ->
  console.log 'connected'

flush = ->
  return if inflight or !pending?
  inflight = pending
  pending = null
  ws.send JSON.stringify {a:'op', op:inflight, v:version}

submit = (op) ->
  type.checkValidOp op

  state = type.apply state, op
  if pending
    pending = type.compose pending, op
  else
    pending = op

  flush()
  render state
