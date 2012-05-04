PluginBase = require('../lib/plugin/plugin.base').PluginBase
Packet = require('../net/connection/packet').Packet

class Echo extends PluginBase

    description: "Echo"

    commands: =>
        echo: @echo
        quit: @quit

    execute: (connection, msgPacket) =>
        super connection, msgPacket


    echo: (connection, msgPacket) =>
        msg = new Packet msgPacket.separator, "echoed", [msgPacket.messageFragments[0]]
        connection.send msg
    quit: (connection, msgPacket) =>
        connection.disconnect()


exports.Plugin = Echo
