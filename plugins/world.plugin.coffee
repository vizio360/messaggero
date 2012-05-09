PluginBase = require('../lib/plugin/plugin.base').PluginBase
Packet = require('../net/connection/packet').Packet
fs = require 'fs'
Connection = require('../net/connection/connection').Connection


class World extends PluginBase

    description: "World"

    commands: =>
        world: @world
        join: @join
        listConnections: @listConnections
        leave: @leave


    constructor: ->
        @worlds = {}
        fs.readFile './data/worlds.json', 'utf8', @loadWorlds
        super

    loadWorlds: (err, data) =>
        worlds = JSON.parse data
        # create each room
       
        for world, rooms of worlds
            @worlds[world] = {}
            @worlds[world]["rooms"] = {}
            @worlds[world]["rooms"]["lobby"] = new Room("lobby")
            for room in rooms
                r = new Room(room)
                @worlds[world]["rooms"][room] = r


    execute: (connection, msgPacket) =>

        # users need to be logged in to be able to
        # use the chat
        if msgPacket.command != "listConnections"
            if not (connection.getData("username")?)
                #console.log "not logged in"
                return

        super connection, msgPacket


    world: (connection, msgPacket) =>
        
        if msgPacket.messageFragments.length != 1
            msg = new Packet msgPacket.separator, "KO", ["bad request"]
            return connection.send msg

        worldToJoin = msgPacket.messageFragments[0]
        if not @worlds[worldToJoin]?
            msg = new Packet msgPacket.separator, "world", ["NO",worldToJoin]
            return connection.send msg

        # automatically join the lobby

        connection.setData "world", worldToJoin
        connection.setData "room", "lobby"

        #console.log "about to join lobby "+connection.id
        @worlds[worldToJoin]["rooms"]["lobby"].join(connection)
        msg = new Packet msgPacket.separator, "world", ["IN", worldToJoin]
        connection.send msg

    join: (connection, msgPacket) =>

        if msgPacket.messageFragments.length != 1
            msg = new Packet msgPacket.separator, "KO", ["bad request"]
            return connection.send msg

        roomToJoin = msgPacket.messageFragments[0]
        currentWorld = connection.getData("world")
       
        
        if not (currentWorld?)
            msg = new Packet msgPacket.separator, "KO", ["not in a world"]
            return connection.send msg

        currentRoom = connection.getData("room")

        if not (@worlds[currentWorld]["rooms"][roomToJoin]?)
            msg = new Packet msgPacket.separator, "room", ["NO", roomToJoin]
            return connection.send msg


        @worlds[currentWorld]["rooms"][currentRoom].leave(connection)


        process.nextTick =>
            msg = new Packet msgPacket.separator, "room", ["IN", roomToJoin]
            connection.send msg

            process.nextTick =>
                @worlds[currentWorld]["rooms"][roomToJoin].join(connection)


        #room = @worlds[currentWorld]["rooms"][roomToJoin]

        #msg = new Packet msgPacket.separator, "users", room.getUsers()
        #connection.send msg


    leave: (connection, msgPacket) =>
        
        currentWorld = connection.getData("world")
        currentRoom = connection.getData("room")
        return if not currentWorld? or not currentRoom?
        @worlds[currentWorld]["rooms"][currentRoom].leave(connection)
        msg = new Packet msgPacket.separator, "room", ["OUT", currentRoom]
        connection.send msg




    unregister: =>
        # FIXME the following is completely wrong
        for world, rooms of @worlds
            for room of rooms
                room.destroy()


    
    listConnections: (connection, msgPacket) =>
        console.log "listConnections"
        for world of @worlds
            console.log "world: "+world
            for room of @worlds[world]["rooms"]
                console.log "room: "+room
                count = 0
                count += 1 for c of @worlds[world]["rooms"][room].connections
                connids = ""
                connids += cid+"|" for cid of  @worlds[world]["rooms"][room].connections
                console.log "conn: "+count+" "+connids


    onConnectionDisconnected: (connection) =>



exports.Plugin = World



class Room

    # if I declare this varialbe here it behaves like
    # it's a static one... no idea why
    # connections: {}

    constructor: (@id) ->
        @connections = {}

    join: (connection) =>
        #console.log connection.getData("username"), "joining", @id
        @connections[connection.id] =  connection
        connection.setData "room", @id
        connection.on Connection.PACKET_BROADCAST_EVENT, @broadcast
        connection.on Connection.DISCONNECT_EVENT, @removeConnection

    leave: (connection) =>
        #console.log connection.getData("username"), "leaving", @id
        @removeConnection connection

    broadcast: (sourceConnection, sourcePacket, args...) =>
        return if sourceConnection.getData("room") isnt @id
        for id, connection of @connections
            # we don't want to echo back
            if sourceConnection.id isnt id
                connection.send sourcePacket

    getUsers: =>
        users = new Array()
        for connection in @connections
            users.push connection.getData "username"
        return users


    removeConnection: (connection) =>
        connection.setData "room", ""
        connection.removeListener Connection.PACKET_BROADCAST_EVENT, @broadcast
        connection.removeListener Connection.DISCONNECT_EVENT, @removeConnection
        delete @connections[connection.id]

    destroy: =>
        @connections = null
