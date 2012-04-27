PluginManager = require('./lib/plugin/plugin_manager').PluginManager
fs = require 'fs'
Connection = require('./net/connection/connection').Connection
Packet = require('./net/connection/packet').Packet
async = require('async')


### Loading plugins ###
pm = new PluginManager()

pluginDir = "./plugins"


loadPlugins = (callback) ->

    console.log "loading plugins"
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
        callback null, 1


# loading configuration #
configuration = {}

loadConfiguration = (callback) ->
    console.log "loading configuration"
    fs.readFile './config.json', 'utf8', (err, data) ->
        configuration = JSON.parse data
        callback null, 2

server = null
startApplication = (err, results)->
    console.log "loading application"
    Server = require('./net/server/'+configuration.serverType).Server
    server = new Server configuration.port
    server.on Server.NEW_CONNECTION_EVENT, onNewConnection
    server.on Server.DATA_EVENT, onData
    server.on Server.DISCONNECTION_EVENT, onDisconnection
    server.startListening()
    

async.series [loadPlugins, loadConfiguration], startApplication

onNewConnection = (connection) ->
    console.log "new connection", connection.id
    #pm.onNewConnection connection

onData = (connection, data) ->
    console.log "data received from connection", connection.id

    separator = data.charAt(0)
    data = data.split separator
    command = data[1]
    messageContent = data[2..]

    msgPacket = new Packet separator, command, messageContent

    pm.execute connection, msgPacket


onDisconnection = (connection) ->
    console.log "connection ended", connection.id
