fs = require 'fs'
Connection = require('../connection').Connection
Packet = require('../packet').Packet

class Login

    description: "Login"

    commands: =>
        login: @login,
        logout: @logout

    constructor: ->
        fs.readFile './data/users.json', 'utf8', @loadUsers

    loadUsers: (err, data) =>
        @users = JSON.parse data


    #notifications from plugin manager
    onNewConnection: (connection) =>

    onConnectionDisconnected: (connection) =>
    #--

    execute: (connection, msgPacket) =>
        @commands()[msgPacket.command](connection, msgPacket)
        connection.socket.write msgPacket.command+" executed"


    login: (connection, msgPacket) =>

        if msgPacket.messageFragments.length != 3
            msg = new Packet msgPacket.separator, "KO", ["bad request"]
            return connection.emit Connection.SEND_PACKET_EVENT, msg

        [username, timestamp, token] = msgPacket.messageFragments

        if not @users[username]?
            msg = new Packet msgPacket.separator, "KO", ["User doesn't exist!"]
            return connection.emit Connection.SEND_PACKET_EVENT, msg

        if @users[username] != token
            msg = new Packet msgPacket.separator, "KO", ["wrong credentials"]
            return connection.emit Connection.SEND_PACKET_EVENT, msg

        connection.setData "username", username

        msg = new Packet msgPacket.separator, "OK", ["YEAH!!!"]
        return connection.emit Connection.SEND_PACKET_EVENT, msg


    logout: (connection, msgPacket) =>
        console.log "logging out "+connection.getData "username"
        connection.removeData "username"
        


exports.Plugin = Login
