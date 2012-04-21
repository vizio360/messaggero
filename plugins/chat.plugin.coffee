class Chat
    description: "Chat"
    commands: =>
        say: @say

    execute: (connection, msgPacket) =>
        # users need to be logged in to be able to
        # use the chat
        if not (connection.getData("username")?)
            console.log "not logged in"
            return

        @commands()[msgPacket.command](msgPacket)


    say: (msgPacket) ->
        console.log "saying in "+msgPacket.messageFragments



exports.Plugin = Chat
