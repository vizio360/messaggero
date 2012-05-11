PluginManager = require('./lib/plugin/plugin_manager').PluginManager
fs = require 'fs'
Connection = require('./net/connection/connection').Connection
Packet = require('./net/connection/packet').Packet
async = require('async')
program = require('commander')


### Loading plugins ###
pm = new PluginManager()

loadPlugins = (callback) ->

    console.log "loading plugins"
    fs.readdir pm.pluginDir, (err, files) =>
        if err?
            console.log err
        else
            for file in files
                #removing the coffee extension
                file = file.split(".")
                # check if it is a coffee file
                continue if file[file.length-1] != "coffee"
                # rebuild filename without coffee extension
                file = file[0...-1].join(".")
                console.log file
                pm.registerByName file
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
    program.option('-p, --port [value]', 'port hermes listens to').parse(process.argv)
    configuration.port = if (program.port?) then program.port else configuration.port
    Server = require('./net/server/'+configuration.serverType).Server
    server = new Server configuration.port
    server.on Server.NEW_CONNECTION_EVENT, onNewConnection
    server.on Server.DATA_EVENT, onData
    server.on Server.DISCONNECTION_EVENT, onDisconnection
    server.startListening()
    
# loading plugins and configuration files before starting the app
async.series [loadPlugins, loadConfiguration], startApplication

onNewConnection = (connection) ->
    pm.onNewConnection connection # on every new connection each plugin is notified

onData = (connection, data) ->

    separator = data.charAt(0)
    data = data.split separator
    command = data[1]
    messageContent = data[2..]

    msgPacket = new Packet separator, command, messageContent
    pm.execute connection, msgPacket


onDisconnection = (connection) ->
    pm.onConnectionDisconnected connection # on every lost connection each plugin is notified
