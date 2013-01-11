chai        = require 'chai'
after       = require('fluent-time').after
should      = chai.should()
expect      = chai.expect

lies        = require '../src/beautiful-lies'
createLiar  = lies.createLiar

describe 'callback_result plugin', ->

  liar = {}

  before ->

    liar = createLiar [
      function_name: 'count_async'
      callback_result: {
        value: 'Four plus four is eight!'
      }
    ]

  it 'should behave as expected', (done) ->

    liar.count_async (err, result) ->
      result.should.equal 'Four plus four is eight!'
      done()

describe 'on_callback_result + callback_error_value plugin', ->

  liar = {}

  before ->
    liar = createLiar [
      function_name: 'connect'
      on_callback_result: [
        function_name: 'query'
        callback_error_value:
          type: 'ConnectionError'
          message: 'Connection was terminated.'
      ]

    ]

  it 'should behave as expected', (done) ->
    liar.connect (error, connection) ->
      connection.query (error, result) ->
        error.type.should.equal 'ConnectionError'
        error.message.should.equal 'Connection was terminated.'
        done()


describe 'callback_error plugin', ->

  liar = {}

  before ->

    liar = createLiar [
      function_name: 'bark_async'
      callback_error_value: {
        message: 'Cats cannot bark!'
      }
    ]

  it 'should behave as expected', (done) ->

    liar.bark_async (error, result) ->
      error.message.should.equal 'Cats cannot bark!'
      done()

describe 'promise_done plugin', ->

  liar = {}

  before ->
    liar = createLiar [
      function_name: 'connect'
      promise_done:
        on_value: [
          function_name: 'query'
          promise_done_value: [ 'John', 'Martha', 'Luke' ]
        ]
    ]

  it 'should behave as expected', (done) ->
    liar.connect().done (connection) ->
      connection.query().done (result) ->
        result[0].should.equal 'John'
        result[2].should.equal 'Luke'
        done()

  it 'should have an implicit fail', (done) ->
    failExecuted = false
    liar.connect().fail -> failExecuted = true
    after(100).milliseconds ->
      failExecuted.should.equal false
      done()

  it 'should allow chaining done and fail', (done) ->
    liar.connect().done (connection) ->
      connection.query().fail( ->
        # Implementation not important
      ).done (result) ->
        result[2].should.equal 'Luke'
        done()

  it 'should allow chaining fail and done (in reversed order)', (done) ->
    liar.connect().done (connection) ->
      connection.query().done((result) ->
        result[2].should.equal 'Luke'
        done()
      ).fail( ->
        # Implementation not important
      )




describe 'on_promise_done plugin', ->

  liar = {}

  before ->

    liar = createLiar [
      function_name: 'connect'
      on_promise_done: [
        function_name: 'query'
        promise_done_value: [ 'John', 'Martha', 'Luke' ]
      ]
    ]

  it 'should behave as expected', (done) ->
    liar.connect().done (connection) ->
      connection.query().done (result) ->
        result[0].should.equal 'John'
        result[2].should.equal 'Luke'
        done()

describe 'promise_done_value plugin', ->

  cat = {}

  before ->

    cat = createLiar [
      function_name: 'meow_async'
      promise_done_value: 'Meow!'
    ]

  it 'should behave as expected', (done) ->
    cat.meow_async().done (result) ->
      result.should.equal 'Meow!'
      done()

describe 'promise_done_value plugin (null)', ->

  cat = {}

  before ->
    cat = createLiar [
      function_name: 'idle_async'
      promise_done_value: null
    ]

  it 'should run callback and get no arguments', (done) ->
    cat.idle_async().done (result) ->
      expect(result).to.equal null
      done()




describe 'promise_fail plugin', ->

  dog = {}

  beforeEach ->

    dog = createLiar [
      function_name: 'meow_async'
      promise_fail:
        value: "Dogs don't meow!"
    ]

  it 'should behave as expected', (done)->
    dog.meow_async().fail (error) ->
      error.should.equal "Dogs don't meow!"
      done()

  it 'should handle done implicitly', (done) ->
    doneExecuted = false
    dog.meow_async().done ->
      doneExecuted = true
    after(100).milliseconds ->
      doneExecuted.should.equal false
      done()

  it 'should allow chaining done', (done) ->
    dog.meow_async().fail( (error) ->
      error.should.equal "Dogs don't meow!"
      done()
    ).done ->
      # implementation not important

  it 'should allow chaining fail on implicit done', (done) ->
    dog.meow_async().done( ->
      # implementation not important
    ).fail (error) ->
      error.should.equal "Dogs don't meow!"
      done()



  #it 'should allow chaining fail and done (in reversed order)', (done) ->



describe 'promise_fail_value plugin', ->

  dog = {}

  before ->

    dog = createLiar [
      function_name: 'meow_async'
      promise_fail_value: "Dogs don't meow!"
    ]

  it 'should behave as expected', (done)->
    dog.meow_async().fail (error) ->
      error.should.equal "Dogs don't meow!"
      done()