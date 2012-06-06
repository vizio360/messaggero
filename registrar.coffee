http = require('http')
# FIXME
# look at https://github.com/danwrong/restler 
# for a rest client API

class Registrar

    options:
        host: 'localhost'
        port: 3000
        method: 'PUT'
        headers:
            "Content-Type": "application/json"

    getEc2InstanceInfo: (cb) =>
        @ec2InstanceId = "ec2123123"
        @ip = "192.168.0.1"
        cb()


    register: (configuration, cb) =>

        path = "/hermes/#{configuration.id}"
        @options.path = path
        req = http.request @options, (res) ->
            console.log res.statusCode
            cb()

        body =
            maxConnections: configuration.maxConnections
            ip: @ip
            port: configuration.port
            machineId: @ec2InstanceId


        req.end(JSON.stringify(body))

exports.Registrar = Registrar
