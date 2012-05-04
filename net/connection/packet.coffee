class Packet
    constructor: (@separator, @command, @messageFragments) ->


    stringify: (send_crlf = true) =>

        crlf = if send_crlf then '\r\n' else ""
        @separator + @command + @separator + @messageFragments.join(@separator) + crlf


exports.Packet = Packet
