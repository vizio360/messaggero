http = require 'http'
WebSocketServer = require('websocket').server
BaseServer = require('./server.base').BaseServer
Connection = require('../connection/connection').Connection

class WebSocketServer extends BaseServer

    constructor: (@port) ->
        @server = http.createServer (request, response) ->
        super

    writeMethod: (msg) ->
        @socket.sendUTF msg

    onConnectionEstablished: (request) =>
        console.log "connection established"
        socket = request.accept(null, request.origin)
        socket.id = @getUniqueID()
        
        currentConnection = new Connection(socket, {}, @writeMethod)
        @addConnection currentConnection


        @emit WebSocketServer.NEW_CONNECTION_EVENT, currentConnection


        socket.on 'close', =>
            console.log "server disconnected"
            connection = @getConnection socket.id
            connection.disconnect()
            connection.removeAllListeners()
            @emit WebSocketServer.DISCONNECTION_EVENT, connection
            @removeConnection socket.id

        socket.on 'message', (data) =>
            if (data.type != 'utf8')
                return
            data = data.utf8Data

            # removing \r\n character
            data = data.substring(0, data.length-2) while (data.length > 1 and data.charAt(data.length-2) == '\r' and data.charAt(data.length-1) == '\n')

            @emit WebSocketServer.DATA_EVENT, @getConnection(socket.id), data


    startListening: =>
        @server.listen @port, =>
            console.log "server started listening on port", @port
        @wsServer = new WebSocketServer { httpServer: @server }
        @wsServer.on 'request', @onConnectionEstablished


exports.Server = WebSocketServer
