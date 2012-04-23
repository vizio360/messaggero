class PluginBase

    #notifications from plugin manager
    onNewConnection: (connection) =>

    onConnectionDisconnected: (connection) =>
    #--

    execute: (connection, msgPacket) =>
        @commands()[msgPacket.command](connection, msgPacket)

exports.PluginBase = PluginBase
