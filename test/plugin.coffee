chai        = require 'chai'
should      = chai.should()
expect      = chai.expect
create_liar = require '../create_liar'

describe 'callback_result plugin', ->

  liar = {}

  before ->

    liar = create_liar [
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
    liar = create_liar [
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

    liar = create_liar [
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

    liar = create_liar [
      function_name: 'meow_async'
      promise_done: 'Meow!'
    ]

  it 'should behave as expected', (done) ->
    liar.meow_async().done (result) ->
      result.should.equal 'Meow!'
      done()

describe 'promise_fail plugin', ->

  liar = {}

  before ->

    liar = create_liar [
      function_name: 'meow_async'
      promise_fail: "Dogs don't meow!"
    ]

  it 'should behave as expected', ->
    liar.meow_async().fail (error) ->
      error.should.equal "Dogs don't meow!"