class Connection
    constructor: (@socket, @data={}) ->

    setData: (key, value) ->
        @data[key] = value

    getData: (key) ->
        @data[key]
        
exports.Connection = Connection
