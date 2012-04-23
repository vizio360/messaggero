fs = require 'fs'
Connection = require('../connection').Connection
Packet = require('../packet').Packet

class AnonymousLogin

    @userCount: 0
    description: "AnonymousLogin"

    commands: =>
        login: @login,
        logout: @logout

    constructor: ->



    #notifications from plugin manager
    onNewConnection: (connection) =>

    onConnectionDisconnected: (connection) =>
    #--

    execute: (connection, msgPacket) =>
        @commands()[msgPacket.command](connection, msgPacket)
        connection.write msgPacket.command+" executed"


    login: (connection, msgPacket) =>

        if msgPacket.messageFragments.length != 1
            msg = new Packet msgPacket.separator, "KO", ["bad request"]
            return connection.emit Connection.SEND_PACKET_EVENT, msg

        [username] = msgPacket.messageFragments

        connection.setData "username", username+"-"+AnonymousLogin.userCount
        AnonymousLogin.userCount += 1

        msg = new Packet msgPacket.separator, "OK", ["YEAH!!!"]
        return connection.emit Connection.SEND_PACKET_EVENT, msg


    logout: (connection, msgPacket) =>
        console.log "logging out "+connection.getData "username"
        connection.removeData "username"
        


exports.Plugin = AnonymousLogin
