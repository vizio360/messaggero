net = require 'net'
BaseServer = require('./server.base').BaseServer
Connection = require('../connection/connection').Connection

class TCPServer extends BaseServer

    constructor: (@port) ->
        @server = net.createServer (@onConnectionEstablished)
        super

    writeMethod: (msg) ->
        #@socket.sendUTF msg
        @socket.write msg

    onConnectionEstablished: (socket) =>
        socket.setEncoding 'ascii'
        socket.id = @getUniqueID()
        
        currentConnection = new Connection(socket, {}, @writeMethod)
        @addConnection currentConnection


        @emit TCPServer.NEW_CONNECTION_EVENT, currentConnection


        socket.on 'end', =>
            console.log "server disconnected"
            connection = @getConnection socket.id
            connection.removeAllListeners()
            @emit TCPServer.DISCONNECTION_EVENT, connection
            @removeConnection socket.id

        socket.on 'data', (data) =>
            console.log "data received", data
            console.log data.indexOf("\r\n")
            console.log data.indexOf("\r")
            console.log data.indexOf("\n")
            data = data.split "\r\n"

            for d in data
                @emit TCPServer.DATA_EVENT, @getConnection(socket.id), d if d != ""




    startListening: =>
        @server.listen @port, =>
            console.log "server started listening on port", @port


exports.Server = TCPServer
