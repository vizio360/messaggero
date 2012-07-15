async = require('async')
rest = require('restler')

class Registrar

    getEc2InstanceInfo: (configuration, cb) =>
        aws = configuration.amazonMetaDataWS
        data =
            id:async.apply(@getInfo, aws + 'instance-id')
            dns:async.apply(@getInfo, aws + 'public-hostname')
            
        async.parallel data, (err, results) =>
            # FIXME we should handle the error here
            # maybe sending an email
            # or setting the values to something
            # that explains the problem
            @ec2InstanceId = results.id
            @ip = results.dns
            cb()

    getInfo: (endPoint, callback) ->
        rest.get(endPoint).on 'complete', (result) =>
            callback(null, result)

        

    register: (configuration, cb) =>

        path = "/hermes/#{configuration.uuid}"
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
