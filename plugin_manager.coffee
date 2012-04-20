class PluginManager

    pluginMap: {}

    register: (plugin) ->
        for command of plugin.commands()
            @pluginMap[command] = plugin

    execute: (command, data, originalMessage) ->

        plugin = @pluginMap[command]

        if plugin?
            plugin.execute(command, data)
        else
            console.log "no plugin to handle message:#{originalMessage}"

exports.PluginManager = PluginManager
