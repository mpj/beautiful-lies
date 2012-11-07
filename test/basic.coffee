chai        = require 'chai'
should      = chai.should()
expect      = chai.expect

lies        = require '../src/beautiful-lies'
createLiar = lies.createLiar

describe 'createLiar', ->

  it 'Should simulate a function call', ->

    liar = createLiar [
      function_name: 'someFunction'
      returns:
        value:
          someProperty: 5
    ]

    liar.someFunction().should.deep.equal
      someProperty: 5

  it 'should treat a single object the same was as an array of one', ->

    liar = createLiar # Look ma, no array!
      function_name: 'someFunction'
      returns:
        value:
          someProperty: 5

    liar.someFunction().should.deep.equal
      someProperty: 5


  describe 'arguments provided', ->

    liar = createLiar [
        function_name: 'funkyFunction'
        arguments: [ 'apples' ]
        returns:
          value: 98
    ]

    it 'Should not work with wrong arguments', ->

      (->
        liar.funkyFunction 'oranges'
      ).should.throw(
        "funkyFunction called with unexpected arguments. " +
        "Actual: oranges" +
        "Possible: apples"
      )

    it 'But it will work with right one', ->

      liar.funkyFunction('apples')
        .should.equal 98

  describe 'Multiple lies', ->

    liar = createLiar [
      {
        function_name: 'authorize'
        returns:
          value: 98
      },{
        function_name: 'charge'
        returns:
          value: 'OK'

      }
    ]

    it 'should return stuff', ->
      liar.authorize().should.equal 98
      liar.charge().should.equal 'OK'


  describe 'Expectations should be nestable', ->

    liar = createLiar [
      function_name: 'connect'
      returns:
        value: { status: 'open' }
        on_value: [
          function_name: 'query'
          returns:
            value: '5 little pigs'
        ]
    ]

    it 'should be possible to call inner functions', ->

      connection = liar.connect()
      connection.status.should.equal 'open'
      connection.query().should.equal '5 little pigs'

it 'should match to right lie if multiple per function', ->
  liar = createLiar [{
    function_name: 'add'
    arguments: [2, 3]
    returns:
      value: 5
  },{
    function_name: 'add'
    arguments: [5, 4]
    returns:
      value: 9
  }]
  liar.add(2,3).should.equal 5
  liar.add(5,4).should.equal 9




describe 'Syntax checking', ->

  it 'should validate that return has a value property', ->
    (->
      liar = createLiar [
        function_name: 'something'
        returns:
          values: 'somevalue' # <- spelled wrong, an "s" at the end!
      ]
      liar.something()

    ).should.throw 'returns object must have property "value" or "on_value"'

  it 'should validate function_name of root', ->
    (->
      liar = createLiar [
        function: 'do_stuff' # forgot _name
      ]
    ).should.throw 'lies must have property "function_name"'

  it 'should validate that arguments is an array (root)', ->
    (->
      liar = createLiar [
        function_name: 'woop'
        arguments: 'hats' # forgot the array brackets
      ]
      liar.woop()
    ).should.throw 'arguments must be of type Array.'

  it 'should validate that function is string', ->
    (->
      myFunc = -> # just declare a random function
      liar = createLiar [
        function_name: myFunc
        returns: 9
      ]
    ).should.throw 'function_name must be a string.'
