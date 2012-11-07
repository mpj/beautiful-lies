chai        = require 'chai'
should      = chai.should()
expect      = chai.expect

lies        = require '../src/beautiful-lies'
createLiar  = lies.createLiar

it 'Value should be implicit if on_value defined', (done) ->

  liar = createLiar [
    function_name: 'connect'
    run_callback_flow: [
      argument_2:
        # Look ma, no value property!
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

