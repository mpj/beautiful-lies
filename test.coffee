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

    


