chai        = require 'chai'
should      = chai.should()
expect      = chai.expect

lies        = require '../src/beautiful-lies'

lies.expect()

describe 'call validation', ->
  sword = null
  beforeEach ->
    sword = {}
    sword.expect {
      function_name: 'cut'
    }

  it 'should have 0 calls before calling', ->
    sword.cut.times_called.should.equal 0

  describe 'when it is called 3 times', ->

    beforeEach ->
      sword.cut()
      sword.cut()
      sword.cut()

    it 'should have 3 calls', ->

      sword.cut.times_called.should.equal 3

  describe 'when called with varying arguments', ->

    beforeEach ->
      sword.cut 'left', 'right'
      sword.cut()
      sword.cut 'down'

    it 'should have the right amount of times_called', ->
      sword.cut.times_called.should.equal 3

    it 'should be possible to check if it was called with two args', ->
      sword.cut.called_with('left', 'right').should.equal true

    it 'should be possible to check if it was NOT called with two args', ->
      sword.cut.called_with('diagonally', 'right').should.equal false








