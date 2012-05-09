PluginBase = require('../lib/plugin/plugin.base').PluginBase
Packet = require('../net/connection/packet').Packet

class Echo extends PluginBase

    ccount: 0

    description: "Echo"

    commands: =>
        echo: @echo
        quit: @quit
        getCC: @getCC

    execute: (connection, msgPacket) =>
        super connection, msgPacket


    echo: (connection, msgPacket) =>
        msg = new Packet msgPacket.separator, "echoed", [msgPacket.messageFragments[0]]
        connection.send msg
    quit: (connection, msgPacket) =>
        connection.disconnect()

    getCC: (connection, msgPacket) =>
        msg = new Packet msgPacket.separator, "ccount", [@ccount]
        connection.send msg

    onNewConnection: (connection) =>
        @ccount += 1

    onConnectionDisconnected: (connection) =>
        @ccount -= 1

exports.Plugin = Echo
