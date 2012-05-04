winston = require('winston')
net = require 'net'
BaseServer = require('./server.base').BaseServer
Connection = require('../connection/connection').Connection

class TCPServer extends BaseServer

    constructor: (@port) ->
        options =
            transports: [new (winston.transports.Console)(), new (winston.transports.File)({ filename: 'error.log' })]
        @logger = new winston.Logger options
        @server = net.createServer @onConnectionEstablished
        super

    writeMethod: (msg) ->

        #console.log "about to write to socket: "+@socket.id
        @socket.write msg


    onConnectionEstablished: (socket) =>
        socket.setEncoding 'utf8'
        socket.id = @getUniqueID()
        
        currentConnection = new Connection(socket, {}, @writeMethod)
        @addConnection currentConnection


        @emit TCPServer.NEW_CONNECTION_EVENT, currentConnection


        socket.on 'end', =>
            #console.log "socket.id "+socket.id+" end. "
            @finalizeDisconnection socket.id


        socket.on 'data', (data) =>
            #console.log socket.id+": data received", data

            data = data.split "\r\n"

            for d in data
                @emit TCPServer.DATA_EVENT, @getConnection(socket.id), d if d != ""

        socket.on 'error', (exception) =>
            @logger.info "socket.id "+socket.id+" error. exception = "+exception

        socket.on 'close', (had_error) =>
            #console.log "socket.id "+socket.id+" closed. had_error = "+had_error
            @finalizeDisconnection socket.id if had_error
            socket.removeAllListeners()
            
            

    finalizeDisconnection: (id) =>
        connection = @getConnection id
        connection.disconnecting()
        connection.removeAllListeners()
        @emit TCPServer.DISCONNECTION_EVENT, connection
        @removeConnection id




    startListening: =>
        @server.listen @port, =>
            console.log "server started listening on port", @port


exports.Server = TCPServer
