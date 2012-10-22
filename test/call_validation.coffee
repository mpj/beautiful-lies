chai        = require 'chai'
should      = chai.should()
expect      = chai.expect
create_liar = require '../create_liar'

sword = {}

describe 'call validation', ->

  beforeEach ->
    sword = create_liar [{
      function_name: 'cut'
    }]

  it 'should have 0 calls before calling', ->
    sword.cut.times_called.should.equal 0

  describe 'when it is called 3 times', ->

    beforeEach ->
      sword.cut()
      sword.cut()
      sword.cut()

    it 'should have 3 calls', ->

      sword.cut.times_called.should.equal 3





