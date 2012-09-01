should      = require('chai').should()
create_liar = require './create_liar'

# TODO
# Array of expectations
# yields
# properly formatted return statement
# validate that expectation is an array (root and on_value)

describe 'create_mock', ->

  it 'Should simulate a function call', ->
    
    liar = create_liar [ 
      function_called: 'someFunction'
      returns:
        value: 
          someProperty: 5
    ]

    liar.someFunction().should.deep.equal
      someProperty: 5

  describe 'with_arguments provided', ->

    liar = create_liar [
        function_called: 'funkyFunction'
        with_arguments: [ 'apples' ]
        returns:
          value: 98
    ]

    it 'Should not work with wrong arguments', ->

      (-> 
        liar.funkyFunction 'oranges'
      ).should.throw(
        "funkyFunction called with unexpected arguments. " +
        "Actual: oranges " + 
        "Expected: apples")

    it 'But it will work with right one', ->

      liar.funkyFunction('apples')
        .should.equal 98

  describe 'Multiple lies', ->

    liar = create_liar [
      {
        function_called: 'authorize'
        returns:
          value: 98
      },{
        function_called: 'charge'
        returns: 
          value: 'OK'
        
      }
    ]

    it 'should return stuff', ->
      liar.authorize().should.equal 98
      liar.charge().should.equal 'OK'


  describe 'Expectations should be nestable', ->

    liar = create_liar [
      function_called: 'connect'
      returns: 
        value: { status: 'open' }
        on_value: [
          function_called: 'query'
          returns: 
            value: '5 little pigs'
        ]
    ]

    it 'should be possible to call inner functions', ->

      connection = liar.connect()
      connection.status.should.equal 'open'
      connection.query().should.equal '5 little pigs'
