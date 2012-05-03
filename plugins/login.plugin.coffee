PluginBase = require('../lib/plugin/plugin.base').PluginBase
Packet = require('../net/connection/packet').Packet
fs = require 'fs'
Connection = require('../net/connection/connection').Connection

class Login extends PluginBase

    description: "Login"

    commands: =>
        login: @login,
        logout: @logout

    constructor: ->
        fs.readFile './data/users.json', 'utf8', @loadUsers
        super

    loadUsers: (err, data) =>
        @users = JSON.parse data


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
