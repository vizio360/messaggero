class PluginBase

    file_name: ""

    #notifications from plugin manager
    onNewConnection: (connection) =>

    onConnectionDisconnected: (connection) =>
    #--

    execute: (connection, msgPacket) =>
        @commands()[msgPacket.command](connection, msgPacket)

    unregister: =>

exports.PluginBase = PluginBase
