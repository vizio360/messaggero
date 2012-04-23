net = require 'net'
PluginManager = require('./plugin_manager').PluginManager
fs = require 'fs'
Connection = require('./connection').Connection
Packet = require('./packet').Packet
WebSocketServer = require('websocket').server
http = require('http')

### Loading plugins ###
pm = new PluginManager()

pluginDir = "./plugins"

fs.readdir pluginDir, (err, files) =>
   for file in files
       #removing the coffee extension
       file = file.split(".")
       # check if it is a coffee file
       continue if file[file.length-1] != "coffee"
       # rebuild filename without coffee extension
       file = file[0...-1].join(".")
       Plugin = require(pluginDir+"/"+file).Plugin
       loadedPlugin = new Plugin()
       pm.register loadedPlugin

   startServer()

### ---------- ###


connections = {}
count = 0

server = http.createServer (request, response) ->

###
server = net.createServer (socket) ->
    socket.setEncoding 'utf8'
    console.log "server connected"

    pm.onNewConnection socket


    socket.id = count
    currentConnection = new Connection(socket)
    # find a better way to identify sockets
    count += 1

    connections[socket.id] = currentConnection
    

    socket.on 'end', ->
        console.log "server disconnected"
        connections[this.id].disconnect()
        connections[this.id].removeAllListeners()
        delete connections[this.id]

    socket.write "hello!\r\n"

    socket.on 'data', (data) ->
        console.log "data received", data
        # removing \r\n character
        if data.length > 1 
            data = data.substring(0, data.length-2) while (data.length > 1 and data.charAt(data.length-2) == '\r' and data.charAt(data.length-1) == '\n')

        separator = data.charAt(0)
        data = data.split separator
        command = data[1]
        messageContent = data[2..]

        msgPacket = new Packet separator, command, messageContent
        

        pm.execute connections[this.id], msgPacket

    ###
wsServer = null
startServer= ->
    server.listen 8124, ->
        console.log "server bound"

    wsServer = new WebSocketServer({
        httpServer: server
        })
    wsServer.on 'request', (request) ->
        console.log "request received"
        socket = request.accept(null, request.origin)

        socket.id = count

        pm.onNewConnection socket

        currentConnection = new Connection(socket)
        # find a better way to identify sockets
        count += 1

        connections[socket.id] = currentConnection



        socket.on 'close', (socket) ->
            console.log "server disconnected"
            connections[this.id].disconnect()
            connections[this.id].removeAllListeners()
            delete connections[this.id]

        socket.sendUTF "hello!"

        socket.on 'message', (data) ->
            if (data.type != 'utf8')
                return
            data = data.utf8Data

            console.log "data received", data
            # removing \r\n character
            if data.length > 1 
                data = data.substring(0, data.length-2) while (data.length > 1 and data.charAt(data.length-2) == '\r' and data.charAt(data.length-1) == '\n')

            separator = data.charAt(0)
            data = data.split separator
            command = data[1]
            messageContent = data[2..]

            msgPacket = new Packet separator, command, messageContent
            

            pm.execute connections[this.id], msgPacket



