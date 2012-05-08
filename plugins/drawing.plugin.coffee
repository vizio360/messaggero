PluginBase = require('../lib/plugin/plugin.base').PluginBase

class Drawing extends PluginBase

    description: "Drawing"

    commands: =>
        drawing: @draw

    execute: (connection, msgPacket) =>
        # users need to be logged in to be able to
        # use the chat
        if not (connection.getData("username")?)
            console.log "not logged in"
            return

        super connection, msgPacket


    draw: (connection, msgPacket) =>
        currentRoom = connection.getData "room"
        return if not(currentRoom?)
        connection.broadcast msgPacket


exports.Plugin = Drawing
