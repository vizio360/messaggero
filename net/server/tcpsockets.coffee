net = require 'net'
BaseServer = require('./server.base').BaseServer
Connection = require('../connection/connection').Connection

class TCPServer extends BaseServer

    constructor: (@port) ->
        @server = net.createServer @onConnectionEstablished
        super

    writeMethod: (msg) ->
        @socket.write msg


    onConnectionEstablished: (socket) =>
        socket.setEncoding 'utf8'
        socket.id = @getUniqueID()
        
        currentConnection = new Connection(socket, {}, @writeMethod)
        @addConnection currentConnection


        @emit TCPServer.NEW_CONNECTION_EVENT, currentConnection


        socket.on 'end', =>


        socket.on 'data', (data) =>
            data = data.split "\r\n"

            for d in data
                @emit TCPServer.DATA_EVENT, @getConnection(socket.id), d if d != ""

        socket.on 'error', (exception) =>
            console.log "socket.id "+socket.id+" error. exception = "+exception

        socket.on 'close', (had_error) =>

            console.log "socket::close an error occured" if had_error
            @finalizeDisconnection socket.id
            socket.removeAllListeners()
            

    finalizeDisconnection: (id) =>
        connection = @getConnection id
        connection.disconnected()
        connection.removeAllListeners()
        @emit TCPServer.DISCONNECTION_EVENT, connection
        @removeConnection id

    startListening: =>
        @server.listen @port, =>
            console.log "server started listening on port", @port

exports.Server = TCPServer
