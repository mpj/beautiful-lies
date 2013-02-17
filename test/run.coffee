chai        = require 'chai'
should      = chai.should()
expect      = chai.expect
after       = require('fluent-time').after
beautiful        = require '../src/beautiful-lies'
beautiful.lie()

describe 'run function', ->

  lastExecuted = null
  callbackExecuted = null
  runFunctionFunctionExecuted = null

  beforeEach (done) ->
    lastExecuted = null
    runFunctionFunctionExecuted = false
    callbackExecuted = false
    bamseBear = {}
    bamseBear.lie
      function_name: 'myFunction'
      run_callback:
        no_arguments: true

      run_function: ->
        lastExecuted = 'run_function'
        runFunctionFunctionExecuted = true

    bamseBear.myFunction () ->
      lastExecuted = 'callback'
      callbackExecuted = true

    after(100).milliseconds -> done()

  it 'runs run_function function', ->
    runFunctionFunctionExecuted.should.equal true

  it 'runs callback', ->
    callbackExecuted.should.equal true

  it 'runs callback after run_function', ->
    lastExecuted.should.equal 'callback'
