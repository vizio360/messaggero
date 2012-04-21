class Login
    description: "Login"
    commands: =>
        login: @login,
        logout: @logout

    execute: (connection, command, data) ->
        @commands()[command](data)
        connection.socket.write command+" executed"


    login: (data) ->
        console.log "logging in "+data

    logout: (data) ->
        console.log "logging out "+data


exports.Plugin = Login
