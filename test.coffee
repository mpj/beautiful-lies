chai        = require 'chai'
should      = chai.should()
expect      = chai.expect
create_liar = require './create_liar'

# TODO
# yield
#  test for conflicts when calling order many times
#  test for calling too many times
#  delay
#  yields must have value or on_value
# yields with null
# Check for value on callback arguments
# Give context to error messages
# times called
# delay
# required
# Maybe some nice debug output
# better variable names ("liar" sucks)
# Some kind of terminology to separate the caller and the callee
#   crazy argument confusion in run_callback
# yield is probably not the greatest word.

describe 'create_liar', ->

  it 'Should simulate a function call', ->

    liar = create_liar [
      function_name: 'someFunction'
      returns:
        value:
          someProperty: 5
    ]

    liar.someFunction().should.deep.equal
      someProperty: 5

  describe 'arguments provided', ->

    liar = create_liar [
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

    liar = create_liar [
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

    liar = create_liar [
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

  describe 'Runs callback', ->

    liar = create_liar [
      function_name: 'connect'
      yields_as_flow: [
        argument_2:
          value: 'connected'
      ]
    ]

    it 'should run callback', (done) ->

      liar.connect (err, status) ->
        status.should.equal 'connected'
        done()

  describe 'Runs callback with error arguments', ->

    liar = create_liar [
      function_name: 'query'
      yields_as_flow: [
        argument_1:
          value:
            message: 'Your query was malformed!'
      ]
    ]

    it 'should run callback with correct arguments', (done) ->

      liar.query (err, status) ->
        err.message.should.equal 'Your query was malformed!'
        done()

  describe 'Runs callback with dual arguments', ->

    liar = create_liar [
      function_name: 'query'
      yields_as_flow: [
        argument_2:
          value: 3
        argument_3:
          value: [ 'Smith', 'Johnson', 'Jackson' ]
      ]
    ]

    it 'should run callback with correct arguments', (done) ->

      liar.query (err, pages, result) ->
        expect(err).to.be.null
        pages.should.equal 3
        result.should.deep.equal [ 'Smith', 'Johnson', 'Jackson' ]
        done()

  describe 'Runs callback flow', ->

    liar = create_liar [
      function_name: 'query'
      yields_as_flow: [
        {
          argument_1:
            value: 'hey'
        },
        {
          argument_1:
            value: 'ho'
        }
      ]
    ]

    it 'should have been run in order', (done) ->
      arr = []
      liar.query (str) ->
        arr.push str
      setTimeout () ->
        arr[0].should.equal 'hey'
        arr[1].should.equal 'ho'
        done()
      , 300

  describe 'Runs callback order', ->

    liar = create_liar [
      function_name: 'query'
      yields_in_order: [
        {
          argument_3:
            value: 'ninjas'
        },
        {
          argument_2:
            value: 'pirates'
        }
      ]
    ]

    it 'should call callbacks in turn', ->

      arr = []
      liar.query (dummy1, dummy2, str) ->
        arr.push str

      arr.length.should.equal 0
      setTimeout () ->

        arr[0].should.equal 'ninjas'
        arr.length.should.equal 1

        liar.query (dummy1, str) ->
          arr.push str

        setTimeout () ->
          arr[1].should.equal 'pirates'
        , 60

      , 60




  it 'should support on_value for callback arguments', (done) ->

    liar = create_liar [
      function_name: 'connect'
      yields_as_flow: [
        argument_2:
          value:
            status: 'open'
          on_value: [
            function_name: 'query'
            returns:
              value:
                size: 72
          ]
      ]
    ]

    liar.connect (err, connection) ->
      connection.query().size.should.equal 72
      done()

it 'should match to right lie if multiple per function', ->
  liar = create_liar [{
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


describe 'Lie validation', ->

  it 'should validate that return has a value property', ->
    (->
      liar = create_liar [
        function_name: 'something'
        returns:
          values: 'somevalue' #spelled wrong!
      ]
      liar.something()

    ).should.throw 'return statement must have property "value"'

  it 'should validate that on_value is an array', ->
    (->
      liar = create_liar [
        function_name: 'do_stuff'
        returns:
          value: {},
          on_value:
            function_name: 'do_more_stuff'
      ]
      liar.do_stuff()
    ).should.throw 'lies must be an array.'

  it 'should validate that root is an array', ->
    (->
      liar = create_liar
        function_name: 'do_stuff'
      liar.do_stuff()
    ).should.throw 'lies must be an array.'

  it 'should validate function_name of root', ->
    (->
      liar = create_liar [
        function: 'do_stuff' # forgot _name
      ]
    ).should.throw 'lies must have property "function_name"'

  it 'should validate function_name of on_value', ->
    (->
      liar = create_liar [
        function_name: 'do_stuff'
        returns:
          value: {}
          on_value: [
            functionn_name: "do_something_else"  # misspelled
          ]
      ]
      liar.do_stuff()
    ).should.throw 'lies must have property "function_name"'

  it 'should validate that arguments is an array (root)', ->
    (->
      liar = create_liar [
        function_name: 'woop'
        arguments: 'hats' # forgot the array brackets
      ]
      liar.woop()
    ).should.throw 'arguments must be of type Array.'

  it 'should validate that arguments is an array (on_value)', ->
    (->
      liar = create_liar [
        function_name: 'birth'
        returns:
          value: {}
          on_value: [
            function_name: 'bark'
            arguments: 7
            returns:
              value: 'Yiff!'
          ]
      ]
      liar.birth().bark(7)
    ).should.throw 'arguments must be of type Array.'

  it 'should validate that function is string', ->
    (->
      myFunc = -> # just declare a random function
      liar = create_liar [
        function_name: myFunc
        returns: 9
      ]
    ).should.throw 'function_name must be a string.'

