EventEmitter = require('events').EventEmitter


class BaseServer extends EventEmitter

    @NEW_CONNECTION_EVENT: "Server::NEW_CONNECTION_EVENT"
    @DATA_EVENT: "Server::DATA_EVENT"
    @DISCONNECTION_EVENT: "Server::DISCONNECTION_EVENT"

    count : 0

    getUniqueID: =>
        # FIXME create ids in a better way
        # maybe using the timestamp
        @count += 1

    constructor: ->
        @connections = {}

    addConnection: (connection) =>
        @connections[connection.id] = connection
        return connection

    getConnection: (id) =>
        @connections[id]

    removeConnection: (id) =>
        delete @connections[socket.id]



    onConnectionEstablished: (socket) =>
        throw Error ("Need to override BaseServer::onConnectionEstablished")


    writeMethod: (msg) ->
        throw Error ("Need to override BaseServer::writeMethod")

    startListening: =>
        throw Error ("Need to override BaseServer::startListening")

exports.BaseServer = BaseServer
