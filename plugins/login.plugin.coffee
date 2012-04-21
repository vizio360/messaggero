fs = require 'fs'
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
        console.log @users["vizio"]

    execute: (connection, msgPacket) =>
        console.log msgPacket
        @commands()[msgPacket.command](connection, msgPacket)
        connection.socket.write msgPacket.command+" executed"


    login: (connection, msgPacket) =>

        if msgPacket.messageFragments.length != 3
            msg = new packet.Packet msgPacket.separator, "KO", ["bad request"]
            return connection.send msg

        [username, timestamp, token] = msgPacket.messageFragments

        if not @users[username]?
            msg = new packet.Packet msgPacket.separator, "KO", ["User doesn't exist!"]
            return connection.send msg

        if @users[username] != token
            msg = new packet.Packet msgPacket.separator, "KO", ["wrong credentials"]
            return connection.send msg

        connection.setData "username", username

        msg = new packet.Packet msgPacket.separator, "OK", ["YEAH!!!"]
        return connection.send msg


    logout: (connection, msgPacket) =>
        console.log "logging out "+connection.getData "username"
        connection.removeData "username"
        


exports.Plugin = Login
