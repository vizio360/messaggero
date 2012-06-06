PluginManager = require('./lib/plugin/plugin_manager').PluginManager
fs = require 'fs'
path = require 'path'
Connection = require('./net/connection/connection').Connection
Packet = require('./net/connection/packet').Packet
async = require('async')
commander = require('commander')
winston = require('winston')
dateformat = require('dateformat')
crypto = require('crypto')
Registrar = require('./registrar').Registrar


### Loading plugins ###
pm = new PluginManager()

loadPlugins = (callback) ->

    console.log "loading plugins"
    fs.readdir pm.pluginDir, (err, files) =>
        if err?
            console.log 'error', err
        else
            for file in files
                #removing the coffee extension
                file = file.split(".")
                # check if it is a coffee file
                continue if file[file.length-1] != "coffee"
                # rebuild filename without coffee extension
                file = file[0...-1].join(".")
                pm.registerByName file
        callback null, 1


# loading configuration #
configuration = {}

loadConfiguration = (callback) ->
    fs.readFile './config.json', 'utf8', (err, data) ->
        console.log 'error', err if err?
        configuration = JSON.parse data
        callback null, 2



# load the uuid from file if it exists
# otherwise create a uuid and save it to file (ID)
loadUUID = (callback) ->
    if path.existsSync("ID")
        UUID = fs.readFileSync './ID', 'utf8'
    else
        UUID = crypto.randomBytes(32).toString('hex')
        file = fs.openSync('./ID', 'w')
        fs.writeSync(file, UUID, 0, UUID.length, 0)
        fs.closeSync(file)
    configuration.id = UUID
    callback null, 3




register = (callback) ->
    registrar = new Registrar()
    # we get ec2 instance info only on startup
    # they should change only on restart of the
    # machine
    registrar.getEc2InstanceInfo (err) ->
        # if err?
        # we should exit and log the error
        registrar.register configuration, (err) ->
            # if err?
            # we should exit and log the error
            console.log "registered"
            callback null, 4



server = null
startApplication = (err, results)->

    logFolder = configuration.logFolder

    commander.option('-p, --port [value]', 'port hermes listens to').parse(process.argv)
    configuration.port = if (commander.port?) then commander.port else configuration.port

    winston.info "loading application"

    now = dateformat(new Date(), "yyyymmddhhMMss")
    winston.add winston.transports.File, { filename: "#{logFolder}/#{now}-hermes-#{configuration.port}.log", 'timestamp':true, 'json':false }
    winston.remove winston.transports.Console
    winston.handleExceptions new winston.transports.File( { filename:"#{logFolder}/#{now}-hermes-#{configuration.port}-exceptions.log", 'timestamp':true } )

    Server = require('./net/server/'+configuration.serverType).Server
    server = new Server configuration.port
    server.on Server.NEW_CONNECTION_EVENT, onNewConnection
    server.on Server.DATA_EVENT, onData
    server.on Server.DISCONNECTION_EVENT, onDisconnection
    server.startListening()
    winston.info "Server started on port #{configuration.port}"

    
# loading plugins and configuration files before starting the app
async.series [loadPlugins, loadConfiguration, loadUUID, register], startApplication

# handling server callbacks
onNewConnection = (connection) ->
    pm.onNewConnection connection # on every new connection each plugin is notified

onData = (connection, data) ->

    return if not connection?

    separator = data.charAt(0)
    data = data.split separator
    command = data[1]
    messageContent = data[2..]

    msgPacket = new Packet separator, command, messageContent
    pm.execute connection, msgPacket


onDisconnection = (connection) ->
    pm.onConnectionDisconnected connection # on every lost connection each plugin is notified



