cp = require('child_process')
program = require('commander')



program.option('--count [value]', 'number of hermes instances')
.option('--startFrom [value]', 'starting port').parse(process.argv)

program.startFrom = parseInt program.startFrom
for i in [1..program.count]
    h = cp.spawn "coffee", ["hermes.coffee", "-p", program.startFrom]
    program.startFrom += 1

