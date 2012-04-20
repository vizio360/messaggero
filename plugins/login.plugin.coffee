class Login
    commands: =>
        login: @login,
        logout: @logout

    execute: (command, data) ->
        @commands()[command](data)


    login: (data) ->
        console.log "logging in "+data

    logout: (data) ->
        console.log "logging out "+data


exports.Plugin = Login
