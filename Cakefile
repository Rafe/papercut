fs            = require 'fs'
{print}       = require 'util'
{spawn, exec} = require 'child_process'

# Read package
pkg = require('./package.json')

bind = (proc)->
  proc.stdout.on 'data', (data) -> print data
  proc.stderr.on 'data', (data) -> print data
  proc.on 'exit', (status) -> callback?() if status is 0

task 'test', 'Run mocha tests', ->
  bind spawn "mocha", ['test']
