PluginBase = require('../lib/plugin/plugin.base').PluginBase
Packet = require('../net/connection/packet').Packet
World = require('./world.plugin').Plugin

class Chat extends PluginBase

    description: "Chat"

    commands: =>
        say: @say

    execute: (connection, msgPacket) =>
        # users need to be logged in to be able to
        # use the chat
        if not (connection.getData("username")?)
            console.log "not logged in"
            return
        
        super connection, msgPacket


    say: (connection, msgPacket) =>
        currentRoom = connection.getData "room"
        return if not(currentRoom?)
        actualMessage = msgPacket.messageFragments[0]
        sourceUsername = connection.getData("username")
        msg = new Packet msgPacket.separator, "sez", [sourceUsername, actualMessage]
        connection.emit World.BROADCAST_TO_ROOM_EVENT+currentRoom, connection, msg


exports.Plugin = Chat
