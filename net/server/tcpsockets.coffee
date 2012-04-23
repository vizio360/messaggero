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
        socket.setEncoding 'utf8'
        socket.id = @getUniqueID()
        
        currentConnection = new Connection(socket, {}, @writeMethod)
        @addConnection currentConnection


        @emit TCPServer.NEW_CONNECTION_EVENT, currentConnection


        socket.on 'end', =>
            console.log "server disconnected"
            connection = @getConnection socket.id
            connection.disconnect()
            connection.removeAllListeners()
            @emit TCPServer.DISCONNECTION_EVENT, connection
            @removeConnection socket.id
            socket.end()

        socket.on 'data', (data) =>
            console.log "data received", data
            # removing \r\n character
            data = data.substring(0, data.length-2) while (data.length > 1 and data.charAt(data.length-2) == '\r' and data.charAt(data.length-1) == '\n')

            @emit TCPServer.DATA_EVENT, @getConnection(socket.id), data


    startListening: =>
        @server.listen @port, =>
            console.log "server started listening on port", @port


exports.Server = TCPServer
