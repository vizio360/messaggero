EventEmitter = require('events').EventEmitter

class Connection extends EventEmitter
    @SEND_PACKET_EVENT: "Connection::SEND_PACKET"
    @DISCONNECT_EVENT: "Connection::DISCONNECT"
    @PACKET_SENT_EVENT: "Connection::PACKET_SENT"


    constructor: (@socket, @data={}) ->
        super
        @id = @socket.id
        @on Connection.SEND_PACKET_EVENT, @onSend


    setData: (key, value) =>
        @data[key] = value

    getData: (key) =>
        @data[key]

    removeData: (key) =>
        delete @data[key]

    onSend: (messagePacket) =>
        @write messagePacket.stringify()
        @emit Connection.PACKET_SENT_EVENT
        
    disconnect: () =>
        # all plugins need to listen to this event
        # and remove all their listeners
        @emit Connection.DISCONNECT_EVENT

    write: (msg) =>
        @socket.sendUTF msg
         
exports.Connection = Connection
