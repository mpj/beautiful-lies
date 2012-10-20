chai        = require 'chai'
should      = chai.should()
expect      = chai.expect
create_liar = require '../create_liar'

describe 'yields_as_flow', ->

  liar = create_liar [
    function_name: 'query'
    yields_as_flow: [
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
    , 300