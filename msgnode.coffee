net = require 'net'
plugin_manager = require './plugin_manager'
fs = require 'fs'



pm = new plugin_manager.PluginManager()

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



server = net.createServer (c) ->
    c.setEncoding 'utf8'
    console.log "server connected"
    c.on 'end', ->
        console.log "server disconnected"
    c.write "hello!\r\n"

    c.on 'data', (data) ->
        originalMessage = data
        separator = data.charAt(0)
        data = data.split separator
        cmd = data[1]
        data = data[1..]
        pm.execute c, cmd, data, originalMessage


startServer= ->
    server.listen 8124, ->
        console.log "server bound"
