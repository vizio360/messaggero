fs = require 'fs'
Connection = require('../net/connection/connection').Connection
PluginBase = require('../lib/plugin/plugin.base').PluginBase
Packet = require('../net/connection/packet').Packet

class AnonymousLogin extends PluginBase

    @userCount: 0
    description: "AnonymousLogin"

    commands: =>
        login: @login,
        logout: @logout

    login: (connection, msgPacket) =>

        if msgPacket.messageFragments.length != 1
            msg = new Packet msgPacket.separator, "KO", ["Anonymous bad request"]
        else
            [username] = msgPacket.messageFragments

            connection.setData "username", username+"-"+AnonymousLogin.userCount
            AnonymousLogin.userCount += 1

            msg = new Packet msgPacket.separator, "OK", ["Anonymous YEAH!!!"]
        connection.send msg


    logout: (connection, msgPacket) =>
        #console.log "logging out "+connection.getData "username"
        connection.removeData "username"
        


exports.Plugin = AnonymousLogin
