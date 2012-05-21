net = require 'net'
winston = require('winston')
BaseServer = require('./server.base').BaseServer
Connection = require('../connection/connection').Connection

class TCPServer extends BaseServer

    constructor: (@port, @socketIdleTimeout = 60000) ->
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

        # handling socket idle timeout
        socket.setTimeout @socketIdleTimeout , =>
            winston.info "connection timed out "+socket.id
            connection = @getConnection socket.id
            if connection?
                connection.disconnect()
            else
                winston.info "connection timed out but no connection object found for socket "+socket.id
                socket.destroy()


        socket.on 'end', =>
            # the close event will be called after this one
            winston.info "connection #{socket.id} ended"

        socket.on 'data', (data) =>
            data = data.split "\r\n"

            for d in data
                @emit TCPServer.DATA_EVENT, @getConnection(socket.id), d if d != ""

        socket.on 'error', (exception) =>
            # the close event will be called after this one
            winston.log 'error', "socket.id "+socket.id+" error. exception = "+exception

        socket.on 'close', (had_error) =>
            winston.info "connection #{socket.id} closed"
            winston.info "socket::close an error occured "+socket.id if had_error
            @finalizeDisconnection socket
            

    finalizeDisconnection: (socket) =>
        id = socket.id
        # stop socket timeout
        socket.setTimeout 0
        connection = @getConnection id
        if not connection?
            winston.info "trying to finilize a connection no longer alive"
        else
            connection.disconnected()
            connection.removeAllListeners()
            @emit TCPServer.DISCONNECTION_EVENT, connection
            @removeConnection id
        socket.destroy()

    startListening: =>
        @server.listen @port, =>
            winston.info "server started listening on port", @port

exports.Server = TCPServer
