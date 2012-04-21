class Chat
    description: "Chat"
    commands: =>
        say: @say

    execute: (connection, command, data) ->
        @commands()[command](data)


    say: (data) ->
        console.log "saying in "+data



exports.Plugin = Chat
