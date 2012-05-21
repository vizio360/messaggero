class PluginManager

    pluginDir: "./plugins"
    pluginMap: {}
    
    pluginRegistered: []


    constructor: ->
        file_name = "admin.plugin"
        Plugin = require("./"+file_name).Plugin
        loadedPlugin = new Plugin(@)
        loadedPlugin.file_name = file_name
        @register loadedPlugin, true
        

    registerByName: (plugin_file_name) =>
        try
            Plugin = require("../../"+@pluginDir+"/"+plugin_file_name).Plugin
        catch err
            console.log err
            return false

        loadedPlugin = new Plugin()
        loadedPlugin.file_name = plugin_file_name
        @register loadedPlugin
        return true



    register: (plugin, permanent = false) =>
        # instead we should get the name of the plugin from
        # the constructor.toString() function
        console.log plugin.description+" loaded\r\n"

        @pluginRegistered.push plugin if not permanent

        for command of plugin.commands()
            @pluginMap[command] or= new Array()
            @pluginMap[command].push plugin
            console.log plugin.description+ " listening for \r\n"+command+" command"
            
    unregisterByName: (plugin_file_name) =>
        for plugin in @pluginRegistered
            if plugin.file_name == plugin_file_name
                @unregister plugin
                return true

        return false


    unregister: (plugin) =>
        plugin_index = @pluginRegistered.indexOf plugin
        if plugin_index == -1
            return
        @pluginRegistered[plugin_index..plugin_index] = []

        plugin.unregister()

        for command, plugins of @pluginMap
            plugin_index = plugins.indexOf plugin
            if plugin_index != -1
                plugins[plugin_index..plugin_index] = []

        name = require.resolve("../../"+@pluginDir+"/"+plugin.file_name)
        delete require.cache[name]

    execute: (connection, msgPacket) =>

        plugins = @pluginMap[msgPacket.command]
        if plugins?.length > 0
            # FIXME we need to catch any exception raised by any plugin
            # and log them
            # FIXME we also need to time each execute and report if a
            # plugin takes more than X amount of time to process a
            # request
            plugin.execute(connection, msgPacket) for plugin in plugins
        else
            console.log "no plugin to handle message:#{msgPacket}"

    onNewConnection: (connection) =>
        plugin.onNewConnection connection for plugin in @pluginRegistered


    onConnectionDisconnected: (connection) =>
        plugin.onConnectionDisconnected connection for plugin in @pluginRegistered

exports.PluginManager = PluginManager
