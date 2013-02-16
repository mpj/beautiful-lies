chai        = require 'chai'
should      = chai.should()
expect      = chai.expect

lies        = require '../src/beautiful-lies'

# TODO change to addLie
describe 'Given that we call init()', ->
  obj = null

  beforeEach ->
    lies.init()
    obj = {}

  describe 'and call addLie on any object', ->
    beforeEach ->
      obj.expect
        function_name: 'someFunction'
        returns:
          value:
            someProperty: 5

    it 'Should simulate a function call', ->
      obj.someFunction().should.deep.equal
        someProperty: 5

    describe 'and adds a lie for another function', ->
      beforeEach ->
        obj.expect
          function_name: 'anotherFunction'
          returns:
            value: 8

      it 'the new lie is in place', ->
        obj.anotherFunction().should.equal 8

      it 'the old lie should still work', ->
        obj.someFunction().someProperty.should.equal 5

  describe 'when we call addLie two times with different expected arguments', ->
    beforeEach ->
      obj.expect
        function_name: 'attackWith'
        arguments: [ 'ninja' ]
        returns:
          value: "Hai!"

      obj.expect
        function_name: 'attackWith'
        arguments: [ 'cowboy' ]
        returns:
          value: "Bang! Bang!"

    it 'should work to call the first one', ->
      obj.attackWith('ninja').should.equal 'Hai!'

    it 'should work to call the second one', ->
      obj.attackWith('cowboy').should.equal 'Bang! Bang!'










