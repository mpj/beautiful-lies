chai        = require 'chai'
should      = chai.should()
expect      = chai.expect

lies        = require '../beautiful-lies'
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
    setTimeout () ->
      arr[0].should.equal 'hey'
      arr[1].should.equal 'ho'
      done()
    , 400