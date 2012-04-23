World = require('./world').Plugin
class Drawing

    description: "Drawing"

    commands: =>
        drawing: @draw

    #notifications from plugin manager
    onNewConnection: (connection) =>

    onConnectionDisconnected: (connection) =>
    #--
    
    execute: (connection, msgPacket) =>
        # users need to be logged in to be able to
        # use the chat
        if not (connection.getData("username")?)
            console.log "not logged in"
            return

        @commands()[msgPacket.command](connection, msgPacket)


    draw: (connection, msgPacket) =>
        currentRoom = connection.getData "room"
        return if not(currentRoom?)
        connection.emit World.BROADCAST_TO_ROOM_EVENT+currentRoom, connection, msgPacket


exports.Plugin = Drawing
