net = require 'net'
BaseServer = require('./server.base').BaseServer
Connection = require('../connection/connection').Connection

class TCPServer extends BaseServer

    constructor: (@port) ->
        @server = net.createServer {allowHalfOpen:false}, @onConnectionEstablished
        super

    writeMethod: (connection, msg) =>
        connection.socket.write msg if not connection.socket.closed

    onConnectionEstablished: (socket) =>
        socket.setEncoding 'utf8'
        socket.id = @getUniqueID()


        
        currentConnection = new Connection(socket, {}, @writeMethod)
        @addConnection currentConnection


        @emit TCPServer.NEW_CONNECTION_EVENT, currentConnection


        socket.setTimeout 60000, =>
            console.log "connection timed out "+socket.id
            @finalizeDisconnection socket.id

        socket.on 'end', =>
            console.log "connection ended"


        socket.on 'data', (data) =>
            data = data.split "\r\n"

            for d in data
                @emit TCPServer.DATA_EVENT, @getConnection(socket.id), d if d != ""

        socket.on 'error', (exception) =>
            # the close vent will be called after this one
            console.log "socket.id "+socket.id+" error. exception = "+exception

        socket.on 'close', (had_error) =>

            console.log "connection #{socket.id} closed"
            console.log "socket::close an error occured "+socket.id if had_error
            @finalizeDisconnection socket.id
            

    finalizeDisconnection: (id) =>
        connection = @getConnection id
        connection.socket.removeAllListeners()
        connection.socket.destroy()
        connection.disconnected()
        connection.removeAllListeners()
        @emit TCPServer.DISCONNECTION_EVENT, connection
        @removeConnection id

    startListening: =>
        @server.listen @port, =>
            console.log "server started listening on port", @port

exports.Server = TCPServer
