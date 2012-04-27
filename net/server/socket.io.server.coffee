http = require 'http'
io = require 'socket.io'

BaseServer = require('./server.base').BaseServer
Connection = require('../connection/connection').Connection

class SocketIOServer extends BaseServer

    constructor: (@port) ->
        @server = http.createServer (request, response) ->
             response.writeHead(200)
             response.end "hello"
        super

    writeMethod: (msg) ->
        @socket.emit msg

    onConnectionEstablished: (socket) =>
        console.log "connected!"
        socket.id = @getUniqueID()
        
        currentConnection = new Connection(socket, {}, @writeMethod)
        @addConnection currentConnection


        @emit SocketIOServer.NEW_CONNECTION_EVENT, currentConnection


        socket.on 'close', =>
            console.log "server disconnected"
            connection = @getConnection socket.id
            connection.disconnect()
            connection.removeAllListeners()
            @emit SocketIOServer.DISCONNECTION_EVENT, connection
            @removeConnection socket.id

        socket.on 'message', (data) =>
            console.log "data ", data
            if (data.type != 'utf8')
                return
            data = data.utf8Data

            # removing \r\n character
            data = data.substring(0, data.length-2) while (data.length > 1 and data.charAt(data.length-2) == '\r' and data.charAt(data.length-1) == '\n')

            @emit SocketIOServer.DATA_EVENT, @getConnection(socket.id), data


    startListening: =>
        app = io.listen @server
        app.set "destroy upgrade", 1
        app.sockets.on 'connection', @onConnectionEstablished
        @server.listen @port, =>
            console.log "server started listening on port", @port


exports.Server = SocketIOServer
