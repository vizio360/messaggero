EventEmitter = require('events').EventEmitter
class Connection extends EventEmitter
    constructor: (@socket, @data={}) ->
        super

    setData: (key, value) =>
        @data[key] = value

    getData: (key) =>
        @data[key]

    removeData: (key) =>
        delete @data[key]

    send: (messagePacket) =>
        @socket.write messagePacket.stringify()
        
exports.Connection = Connection
