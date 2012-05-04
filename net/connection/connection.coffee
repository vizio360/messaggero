EventEmitter = require('events').EventEmitter

class Connection extends EventEmitter
    @DISCONNECT_EVENT: "Connection::DISCONNECT"
    @PACKET_SENT_EVENT: "Connection::PACKET_SENT"
    @PACKET_BROADCAST_EVENT: "Connection::PACKET_BROADCAST"


    constructor: (@socket, @data={}, @writeMethod) ->
        super
        @id = @socket.id


    setData: (key, value) =>
        @data[key] = value

    getData: (key) =>
        @data[key]

    removeData: (key) =>
        delete @data[key]

    send: (messagePacket) =>
        @writeMethod messagePacket.stringify()
        @emit Connection.PACKET_SENT_EVENT
        
    broadcast: (messagePacket, args...) =>
        @emit Connection.PACKET_BROADCAST_EVENT, @, messagePacket, args...

    disconnect: () =>
        # all plugins need to listen to this event
        # and remove all their listeners
        @emit Connection.DISCONNECT_EVENT
        @socket.end()

exports.Connection = Connection
