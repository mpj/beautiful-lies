chai        = require 'chai'
should      = chai.should()
expect      = chai.expect

beautifulLies        = require '../src/beautiful-lies'

beautifulLies.lie()

describe 'lie (basic cases)', ->
  liar = null

  beforeEach ->
    liar = {}

  it 'Should simulate a function call', ->
    liar.lie
      function_name: 'someFunction'
      returns:
        value:
          someProperty: 5

    liar.someFunction().should.deep.equal
      someProperty: 5

  describe 'When returns.self is true', ->
    beforeEach ->
      liar.lie
        function_name: 'superFunction'
        returns:
          self: true

    it 'function should return host object', ->
      liar.superFunction().should.equal liar

  describe 'When returns.self is false', ->
    beforeEach ->
      liar.lie
        function_name: 'superFunction'
        returns:
          self: false
          value: "Superman!"

    it 'function should NOT return host object', ->
      liar.superFunction().should.equal "Superman!"


  describe 'arguments provided', ->
    beforeEach ->
      liar.lie
          function_name: 'funkyFunction'
          arguments: [ 'apples' ]
          returns:
            value: 98

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

  describe 'when we have  check function', ->
    beforeEach ->
      liar.lie
        function_name: 'fancyFunction'
        check: (idea) -> idea is 'Cats with hats'
        returns:
          value: 'Great style!'

    it 'should check the arguments', ->
      liar.fancyFunction('Cats with hats').should.equal 'Great style!'

    describe 'with another check function', ->
      beforeEach ->
        liar.lie
          function_name: 'fancyFunction'
          check: (idea) -> idea is 'Dogs on skateboards'
          returns:
            value: 'Funny!'

      it 'should pick the right one', ->
        liar.fancyFunction('Dogs on skateboards').should.equal 'Funny!'

      it 'should fail if trying a completely different one', ->
        # FIXME This error message really looks like shit... :(
        (->
          liar.fancyFunction('Capybaras with machine guns')
        ).should.throw 'fancyFunction called with unexpected arguments. Actual: Capybaras with machine gunsPossible: Possible: '



  describe 'Multiple lies', ->
    beforeEach ->
      liar.lie [
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
    beforeEach ->
      liar.lie
        function_name: 'connect'
        returns:
          value: { status: 'open' }
          on_value:
            function_name: 'query'
            returns:
              value: '5 little pigs'


    it 'should be possible to call inner functions', ->

      connection = liar.connect()
      connection.status.should.equal 'open'
      connection.query().should.equal '5 little pigs'

  it 'should match to right lie if multiple per function', ->
    liar.lie [{
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
        liar.lie
          function_name: 'something'
          returns:
            values: 'somevalue' # <- spelled wrong, an "s" at the end!

        liar.something()

      ).should.throw 'returns object must have property "value" or "on_value"'

    it 'should validate function_name of root', ->
      (->
        liar.lie
          function: 'do_stuff' # forgot _name
      ).should.throw 'expectation must have property "function_name"'

    it 'should validate that arguments is an array (root)', ->
      (->
        liar.lie
          function_name: 'woop'
          arguments: 'hats' # forgot the array brackets
        liar.woop()
      ).should.throw 'arguments must be of type Array.'

    it 'should validate that function is string', ->
      (->
        myFunc = -> # just declare a random function
        liar.lie
          function_name: myFunc
          returns: 9
      ).should.throw 'function_name must be a string.'

