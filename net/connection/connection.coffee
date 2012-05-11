EventEmitter = require('events').EventEmitter

class Connection extends EventEmitter
    @DISCONNECT_EVENT: "Connection::DISCONNECT"
    @PACKET_SENT_EVENT: "Connection::PACKET_SENT"
    @PACKET_BROADCAST_EVENT: "Connection::PACKET_BROADCAST"


    constructor: (@socket, @data={}, @writeMethod) ->
        super
        @socket.closed = false
        @id = @socket.id


    setData: (key, value) =>
        @data[key] = value

    getData: (key) =>
        @data[key]

    removeData: (key) =>
        delete @data[key]

    send: (messagePacket) =>
        # FIXME would it be better sending out an event
        # which the server.base listens to when a 
        # connection wants to send stuff? instead
        # of passing a function in?
        @writeMethod @, messagePacket.stringify()
        @emit Connection.PACKET_SENT_EVENT
        
    broadcast: (messagePacket, args...) =>
        @emit Connection.PACKET_BROADCAST_EVENT, @, messagePacket, args...

    disconnect: () =>
        @socket.end("bye\r\n")

    disconnected: () =>
        # all plugins need to listen to this event
        # and remove all their listeners
        @socket.closed = true
        @emit Connection.DISCONNECT_EVENT, @


exports.Connection = Connection
