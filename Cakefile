'use strict'

fs = require 'fs'
child_process = require 'child_process'
coffee = require 'coffee-script'

compileCoffee = (coffeePath, jsPath) ->
    try
        cs = fs.readFileSync coffeePath, 'utf8'
        js = coffee.compile cs, bare: true
        fs.writeFileSync jsPath, js
        console.log "#{coffeePath} compiled to #{jsPath}"

    catch e then console.log e


task 'build', 'build coffee to dist directory', ->
    compileCoffee 'mss.coffee', 'dist/mss.js'

task 'test', 'run test', ->
    test = child_process.spawn 'coffee', ['test.coffee']
    test.stdout.on 'data', (data) -> console.log data.toString().trim()

task 'watch', 'build what changed', ->
    invoke 'build'
    fs.watch 'mss.coffee', (event, file) ->
        invoke 'build'
    
    console.log 'Now my watch begin...'



