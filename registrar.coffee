rest = require('restler')

class Registrar

    getEc2InstanceInfo: (configuration, cb) =>
        aws = configuration.amazonMetaDataWS
        rest.get(aws + 'instance-id').on 'complete', (result) =>
            @ec2InstanceId = result
            # FIXME cannot understand why the @ip field
            # is not set. There is a bit of scope creepiness here.
            rest.get(aws + 'public-hostname').on 'complete', (result) =>
                @ip = result
                cb()


    register: (configuration, cb) =>

        path = "hermes/#{configuration.uuid}"
        body =
            maxConnections: configuration.maxConnections
            ip: @ip
            port: configuration.port
            machineId: @ec2InstanceId

        rest.put(configuration.zeusEndPoint+path, {headers: { 'Content-Type': 'application/json' }, data: JSON.stringify(body)}).on 'complete', (data, response)->
            # FIXME should check the response.statusCode
            console.log "registered"
            cb()

exports.Registrar = Registrar
