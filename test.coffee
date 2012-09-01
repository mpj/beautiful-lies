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

  describe 'Expectations should be nestable', ->

    # TODO Better example naming
    liar = create_liar
      function_called: 'outer_function'
      returns: 
        value: { aProperty: 9 }
        on_value: 
          function_called: 'inner_function'
          returns: 
            value: 'inner_return_value'

    it 'should be possible to call inner functions', ->

      outer = liar.outer_function()
      outer.aProperty.should.equal 9
      outer.inner_function().should.equal 'inner_return_value'







    


