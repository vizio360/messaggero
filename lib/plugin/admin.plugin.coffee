Connection = require('../../net/connection/connection').Connection
Packet = require('../../net/connection/packet').Packet
PluginBase = require('./plugin.base').PluginBase

class Plugin_Manager_Plugin extends PluginBase

    constructor: (@plugin_manager) ->

    description: "Admin"

    commands: =>
        plugin: @plugin

    execute: (connection, msgPacket) =>
        super connection, msgPacket


    plugin: (connection, msgPacket) =>
        fragments = msgPacket.messageFragments
        if fragments.length == 0
            msg = new Packet msgPacket.separator, "plugin", ["bad request"]
            connection.send msg
            return

        subcommand = msgPacket.messageFragments[0]
        switch subcommand
            when "load"
                plugin_name = msgPacket.messageFragments[1]
                result = @plugin_manager.registerByName msgPacket.messageFragments[1]
                if not result
                    msg = new Packet msgPacket.separator, "plugin", ["no plugin named "+plugin_name]
                    connection.send msg

            when "unload"
                plugin_name = msgPacket.messageFragments[1]
                result = @plugin_manager.unregisterByName plugin_name
                if not result
                    msg = new Packet msgPacket.separator, "plugin", ["no plugin named "+plugin_name]
                    connection.send msg

            when "list"
                plugins = new Array()
                plugins.push plugin.file_name for plugin in @plugin_manager.pluginRegistered
                msg = new Packet msgPacket.separator, "plugin_registered", plugins
                connection.send msg
            when "listcommands"
                plugins = new Array()
                for plugin in @plugin_manager.pluginRegistered
                    str = plugin.file_name+"@"
                    for command of plugin.commands()
                        str += command+"|"
                    plugins.push str
                msg = new Packet msgPacket.separator, "plugin_commands", plugins
                connection.send msg


    
    #notifications from plugin manager
    onNewConnection: (connection) =>

    onConnectionDisconnected: (connection) =>
    #--

exports.Plugin = Plugin_Manager_Plugin
