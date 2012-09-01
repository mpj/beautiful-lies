should      = require('chai').should()
create_liar = require './create_liar'

describe 'create_mock', ->
  it 'Should simulate a function call', ->
    
    liar = create_liar 
      function_called: 'collection'
      with_arguments: [ 'members' ]
      returns:
        value: 
          someProperty: 5

    liar.collection('members').should.deep.equal
      someProperty: 5

    


