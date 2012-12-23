chai        = require 'chai'
should      = chai.should()
expect      = chai.expect

lies        = require '../src/beautiful-lies'
lie         = lies.lie
createLiar  = lies.createLiar

describe 'run funciton', ->

  lastExecuted = null
  callbackExecuted = null
  runFunctionFunctionExecuted = null

  beforeEach (done) ->
    lastExecuted = null
    runFunctionFunctionExecuted = false
    callbackExecuted = false

    bamseBear = createLiar
      function_name: 'myFunction'
      run_callback:
        argument_1:
          value: 'whatever'
      run_function: ->
        lastExecuted = 'run_function'
        runFunctionFunctionExecuted = true

    bamseBear.myFunction () ->
      lastExecuted = 'callback'
      callbackExecuted = true

    setTimeout(done, 100)

  it 'runs run_function function', ->
    runFunctionFunctionExecuted.should.equal true

  it 'runs callback', ->
    callbackExecuted.should.equal true

  it 'runs callback after run_function', ->
    lastExecuted.should.equal 'callback'
