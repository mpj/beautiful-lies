should      = require('chai').should()
create_liar = require './create_liar'

describe 'create_mock', ->
  it 'Should simulate a function call', ->
    
    liar = create_liar 
      function_called: 'someFunction'
      returns:
        value: 
          someProperty: 5

    liar.someFunction().should.deep.equal
      someProperty: 5

  describe 'with_arguments provided', ->

    liar = create_liar
        function_called: 'funkyFunction'
        with_arguments: [ 'apples' ]
        returns:
          value: 98

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




    


