class PluginManager

    pluginMap: {}

    register: (plugin) ->
        # instead we should get the name of the plugin from
        # the constructor.toString() function
        console.log plugin.description+" loaded\r\n"

        for command of plugin.commands()
            @pluginMap[command] = plugin
            console.log plugin.description+ " listening for "+command+" command"
            

    execute: (connection, command, data, originalMessage) ->

        plugin = @pluginMap[command]

        if plugin?
            plugin.execute(connection, command, data)
        else
            console.log "no plugin to handle message:#{originalMessage}"

exports.PluginManager = PluginManager
