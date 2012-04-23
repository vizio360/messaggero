net = require 'net'
PluginManager = require('./plugin_manager').PluginManager
fs = require 'fs'
Connection = require('./connection').Connection
Packet = require('./packet').Packet

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
        # removing \r\n character
        if data.length > 1 and
           data.charAt(data.length-2) == '\r' and
           data.charAt(data.length-1) == '\n'
            data = data.substring(0, data.length-2)

        separator = data.charAt(0)
        data = data.split separator
        command = data[1]
        messageContent = data[2..]

        msgPacket = new Packet separator, command, messageContent
        

        pm.execute connections[this.id], msgPacket


startServer= ->
    server.listen 8124, ->
        console.log "server bound"
