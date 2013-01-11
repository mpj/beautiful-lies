chai        = require 'chai'
should      = chai.should()
expect      = chai.expect
after       = require('fluent-time').after

lies        = require '../src/beautiful-lies'
createLiar = lies.createLiar

describe 'run_callback_flow', ->

  liar = createLiar [
    function_name: 'query'
    run_callback_flow: [
      {
        argument_1:
          value: 'hey'
      },
      {
        argument_1:
          value: 'ho'
      }
    ]
  ]

  it 'should have been run in order', (done) ->
    arr = []
    liar.query (str) ->
      arr.push str
    after(400).milliseconds ->
      arr[0].should.equal 'hey'
      arr[1].should.equal 'ho'
      done()