chai        = require 'chai'
should      = chai.should()
expect      = chai.expect
create_liar = require '../create_liar'

describe 'Runs callback', ->

  liar = create_liar [
    function_name: 'connect'
    run_callback: [
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
    run_callback: [
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
    run_callback: [
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


describe 'Runs callback order', ->

  it 'should call callbacks in turn', ->

    liar = create_liar [
      function_name: 'query'
      run_callback: [
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

  it 'should work with multiple expectations', (done) ->

    liar = create_liar [
      {
        function_name: 'count'
        run_callback: [
          {
            argument_1:
              value: 'one'
          },
          {
            argument_1:
              value: 'two'
          }
        ]
      },{
        function_name: 'bark',
        run_callback: [
          {
            argument_1:
              value: 'woof!'
          },
          {
            argument_1:
              value: 'ruff!'
          }
        ]
      }
    ]

    liar.count (result) ->
      result.should.equal 'one'
      liar.bark (result) ->
        result.should.equal 'woof!'
        liar.count (result) ->
          result.should.equal 'two'
          liar.bark (result) ->
            result.should.equal 'ruff!'
            done()



  describe 'yeild delay', ->

    describe 'when running callback without any delay specified', ->

      result = null

      beforeEach (done) ->
        liar = create_liar [
          function_name: 'query'
          run_callback: [
            {
              argument_1:
                value: '47 ninjas'
            }
          ]
        ]
        liar.query (r) -> result = r
        done()

      it 'should not have called back after 49ms', (done) ->

        setTimeout ->
          should.not.exist result
          done()
        , 10

      it 'should have callbed back after 50ms', (done) ->

        setTimeout ->
          result.should.equal '47 ninjas'
          done()
        , 50

    describe 'when calling back with a delay of 237 ms', () ->


      result = null
      beforeEach (done) ->
        liar = create_liar [
          function_name: 'query'
          run_callback: [
            {
              argument_1:
                value: '49 ninjas'
              delay: 237
            }
          ]
        ]
        liar.query (r) ->
          result = r
        done()

      it 'should not have called back after 236ms', (done) ->

        setTimeout ->
          should.not.exist result
          done()
        , 236

      it 'should have called back after 237ms', (done) ->

        setTimeout ->
          result.should.equal '49 ninjas'
          done()
        , 237



it 'should support on_value for callback arguments', (done) ->

  liar = create_liar [
    function_name: 'connect'
    run_callback: [
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
    connection.status.should.equal 'open'
    connection.query().size.should.equal 72
    done()

describe 'Syntax checking', ->

  it 'should have a nice warning when too few callbacks', ->
    (->
      liar = create_liar [
        function_name: 'kaboom'
        run_callback: [
          {
            argument_1:
              value: 'bam!'
          },
          {
            argument_1:
              value: 'boom!'
          }
        ]
      ]
      liar.kaboom(()->)
      liar.kaboom() # Doesn't have a callback, but should still count.
      liar.kaboom(()->)
    ).should.throw 'kaboom was called 3 times, but only defined 2 run_callback.'

  it 'should not display the nice warning when there is only a single callback result', (done) ->
    liar = create_liar [
      function_name: 'shoot',
      run_callback: [{
        argument_1:
          value: 'pew!'
      }]
    ]

    liar.shoot (res) ->
      res.should.equal 'pew!'
      liar.shoot (res) ->
        res.should.equal 'pew!'
        done()

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