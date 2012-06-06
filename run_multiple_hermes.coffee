cp = require('child_process')
program = require('commander')



program.option('--delay [value]', 'delay betwwen spawing hermeses')
.option('--count [value]', 'number of hermes instances')
.option('--startFrom [value]', 'starting port').parse(process.argv)

program.startFrom = parseInt program.startFrom
program.count = parseInt program.count

nextHermes = 0
i = 1
startHermes = ->
    console.log "port "+program.startFrom
    h = cp.spawn "coffee", ["hermes.coffee", "-p", program.startFrom]
    if i == program.count
        clearInterval nextHermes
    program.startFrom += 1
    i += 1



nextHermes = setInterval startHermes, program.delay
