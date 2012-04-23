class Packet
    constructor: (@separator, @command, @messageFragments) ->


    stringify: =>
        @separator + @command + @separator + @messageFragments.join(@separator) + '\r\n'


exports.Packet = Packet
