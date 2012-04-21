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
       p = require pluginDir+"/"+file
       loadedPlugin = new p.Plugin()
       pm.register loadedPlugin

   startServer()

### ---------- ###


connections = {}

server = net.createServer (c) ->
    c.setEncoding 'utf8'
    console.log "server connected"


    currentConnection = new Connection(c)
    connections[c] = currentConnection
    c.on 'end', ->
        console.log "server disconnected"
        delete connections[this]

    c.write "hello!\r\n"

    c.on 'data', (data) ->
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

        pm.execute connections[c], msgPacket


startServer= ->
    server.listen 8124, ->
        console.log "server bound"
