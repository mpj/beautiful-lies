chai        = require 'chai'
should      = chai.should()
expect      = chai.expect
create_liar = require '../create_liar'

describe 'plugin', ->

  it 'should work', (done) ->

    create_liar.plugins.callback_result = (obj) ->
      yields_in_order: [
        argument_2: obj
      ]

    liar = create_liar [
      function_name: 'count'
      callback_result: {
        value: 'Four plus four is eight!'
      }
    ]

    liar.count (err, result) ->
      result.should.equal 'Four plus four is eight!'
      done()

