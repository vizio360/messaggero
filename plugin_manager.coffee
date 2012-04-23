class PluginManager

    pluginMap: {}
    
    pluginRegistered: []

    register: (plugin) ->
        # instead we should get the name of the plugin from
        # the constructor.toString() function
        console.log plugin.description+" loaded\r\n"

        @pluginRegistered.push plugin

        for command of plugin.commands()
            @pluginMap[command] = plugin
            console.log plugin.description+ " listening for \r\n"+command+" command"
            

    execute: (connection, msgPacket) =>

        plugin = @pluginMap[msgPacket.command]

        if plugin?
            plugin.execute(connection, msgPacket)
        else
            console.log "no plugin to handle message:#{msgPacket}"

    onNewConnection: (connection) =>
        plugin.onNewConnection connection for plugin in @pluginRegistered


    onConnectionDisconnected: (connection) =>
        plugin.onConnectionDisconnected connection for plugin in @pluginRegistered

exports.PluginManager = PluginManager
