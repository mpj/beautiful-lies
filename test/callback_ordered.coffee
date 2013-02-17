chai        = require 'chai'
should      = chai.should()
expect      = chai.expect
after       = require('fluent-time').after
beautiful   = require '../src/beautiful-lies'

beautiful.lie()

# TODO: Add support for simultaneous calls of another (of) callback
# and the handler callback

describe 'Runs callback', ->

  liar = {}

  liar.lie [
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

describe 'Runs callback (result object instead of array of result object)', ->

  liar = {}

  liar.lie [
    function_name: 'connect'
    run_callback:
      argument_2:
        value: 'connected'
  ]

  it 'should run callback', (done) ->

    liar.connect (err, status) ->
      status.should.equal 'connected'
      done()

describe 'Runs callback with error arguments', ->
  liar = {}
  liar.lie [
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
  liar = {}
  liar.lie [
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

describe 'run_callback defined with no_arguments', ->
  liar = {}
  passedToCallback = null

  beforeEach (done) ->
    liar.lie [
      function_name: 'query',
      run_callback: [
        no_arguments: true
      ]
    ]
    liar.query () ->
      passedToCallback = arguments

    after(50).milliseconds -> done()

  it 'runs callback without arguments', ->
    passedToCallback.length.should.equal 0



describe 'Runs callback order', ->


  it 'should call callbacks in turn', ->
    liar = {}
    liar.lie [
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
    after(60).milliseconds ->

      arr[0].should.equal 'ninjas'
      arr.length.should.equal 1

      liar.query (dummy1, str) ->
        arr.push str

      after(60).milliseconds ->
        arr[1].should.equal 'pirates'


  it 'should work with multiple expectations', (done) ->
    liar = {}
    liar.lie [
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
      liar = null
      result = null

      beforeEach (done) ->
        liar = {}

        liar.lie [
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

        after(10).milliseconds ->
          should.not.exist result
          done()

      it 'should have callbed back after 50ms', (done) ->

        after(50).milliseconds ->
          result.should.equal '47 ninjas'
          done()

    describe 'when calling back with a delay of 237 ms', () ->
      liar = null
      result = null
      beforeEach (done) ->
        liar = {}
        liar.lie [
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
        after(236).milliseconds ->
          should.not.exist result
          done()

      it 'should have called back after 237ms', (done) ->
        after(237).milliseconds ->
          result.should.equal '49 ninjas'
          done()

describe 'run_callback has an "of" property', (done) ->

  onLoadResult = null
  onErrorResult = null
  yielded = null
  liar = null

  beforeEach ->
    onLoadResult = null
    onErrorResult = null
    yielded = null
    liar = {}


  describe 'and has one event listener', ->

    beforeEach (done) ->

      liar.lie [
        {
          function_name: 'addEventListener'
        }, {
          function_name: 'loadStuff'
          run_callback:
            of:
              function_name: 'addEventListener'
              arguments: [ 'onLoad' ]
            argument_2:
              value: 'This is a result!'
        }
      ]

      liar.addEventListener 'onLoad', (error, result) ->
        yielded = result
      liar.loadStuff()

      after(100).milliseconds -> done()

    it 'executes addEventListener callback', ->
      yielded.should.equal 'This is a result!'

  describe 'and has multiple event listeners', ->

    beforeEach ->
      liar.lie [
        {
          function_name: 'addEventListener'
          arguments: [ 'onLoad' ]
        }, {
          function_name: 'addEventListener'
          arguments: [ 'onError' ]
        }, {
          function_name: 'loadStuff'
          run_callback: [
            {
              of:
                function_name: 'addEventListener'
                arguments: [ 'onLoad' ]
              argument_1:
                value: 'This is a result!'
            },{
              of:
                function_name: 'addEventListener'
                arguments: [ 'onError' ]
              argument_1:
                value: 'This is an error!'
            }
          ]
        }
      ]

      liar.addEventListener 'onLoad', (result) -> onLoadResult = result
      liar.addEventListener 'onError', (result) -> onErrorResult = result

    describe 'when calling loadStuff the first time', ->
      beforeEach (done) ->
        liar.loadStuff()
        after(60).milliseconds -> done()

      it 'gets the result', ->
        onLoadResult.should.equal 'This is a result!'

      it 'and does not get an error', ->
        expect(onErrorResult).to.equal null

      describe 'but when calling it a second time', ->
        beforeEach (done) ->
          liar.loadStuff()
          after(100).milliseconds -> done()

        it 'gets the error', ->
          onErrorResult.should.equal 'This is an error!'

  describe 'and defines a single argument (as opposed to array)', ->
    beforeEach ->
      liar.lie [
        {
          function_name: 'addEventListener'
          arguments: [ 'onResult' ]
        },{
          function_name: 'loadThings'
          run_callback: {
            of:
              function_name: 'addEventListener'
              arguments: 'onResult' # <- Look ma, no []!
            argument_1:
              value: 'This is a result!'
          }
        }
      ]

    describe 'and loads things', ->
      beforeEach (done) ->
        liar.addEventListener 'onResult', (result) -> onLoadResult = result
        liar.loadThings()
        after(51).milliseconds -> done()

      it 'should get the correct result', ->
        onLoadResult.should.equal 'This is a result!'




  # TODO certain arguments

it 'should support on_value for callback arguments', (done) ->
  liar = {}
  liar.lie [
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

it 'should treat simple objects to on_value the same way as an array with 1 item', (done) ->
  liar = {}
  liar.lie [
    function_name: 'connect'
    run_callback: [
      argument_2:
        value:
          status: 'open'
        on_value: # Same as the above test, but with no array
                  # passed to on_value.
          function_name: 'query'
          returns:
            value:
              size: 72
    ]
  ]

  liar.connect (err, connection) ->
    connection.status.should.equal 'open'
    connection.query().size.should.equal 72
    done()

describe 'Syntax checking', ->
  liar = null
  beforeEach -> liar = {}
  it 'should have a nice warning when too few callbacks', ->
    (->
      liar.lie [
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
    liar.lie [
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
      liar.lie [
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
      liar.lie [
        function_name: 'do_stuff'
        returns:
          value: {}
          on_value: [
            functionn_name: "do_something_else"  # misspelled
          ]
      ]
      liar.do_stuff()
    ).should.throw 'expectation must have property "function_name"'

  it 'should verify that of is an object (string)', ->
    (->
      liar.lie [
        function_name: 'do_things'
        run_callback:
          of: 'otherFunction'
      ]
      liar.do_things()
    ).should.throw 'run_callback.of property was set to "otherFunction" - must be an object.'

  it 'should verify that of is an object (number)', ->
    (->
      liar.lie [
        function_name: 'hello'
        run_callback:
          of: 871
      ]
      liar.hello()
    ).should.throw 'run_callback.of property was set to "871" - must be an object.'

  it 'should throw pretty error message if an of command does\'nt match any callback', ->
    (->
      liar.lie [{
          function_name: 'addEventListener'
          arguments: [ 'onLoad' ]
        },{
          function_name: 'runLoader'
          run_callback:
            of:
              function_name: 'addEventListener'
              arguments: ['onload'] # <- OOPS, a misspelling!
        }
      ]
      liar.addEventListener 'onLoad', ->
      liar.runLoader()
    ).should.throw 'Tried to run callback provided to addEventListener along with arguments [ onload ], but didn\'t find any. Did you misspell function_name or arguments, or perhaps the callback was never passed to addEventListener?'

  it 'should throw a nice error message if too broad a match', ->
    (->
      liar.lie [
        {
          function_name: 'addEventListener'
          arguments: [ 'onLoad' ]
        },
        {
          function_name: 'addEventListener'
          arguments: [ 'onError' ]
        }
        ,{
          function_name: 'doQuery'
          run_callback:
            of:
              function_name: 'addEventListener'
              # Oooops, no arguments here!
        }
      ]
      liar.addEventListener 'onLoad', -> console.log("oh hai")
      liar.addEventListener 'onError', -> console.log("oh hai")
      liar.doQuery()
    ).should.throw 'Tried to run callback provided to addEventListener, but I had multiple choices and could not guess which one was right. You need to provide run_callback.of.arguments.'




