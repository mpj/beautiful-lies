chai        = require 'chai'
should      = chai.should()
expect      = chai.expect
create_liar = require '../create_liar'

# FIXME WHY DOES THIS FAIL IF changed to YIELDS IN ORDER?
it 'Value should be implicit if on_value defined', (done) ->

  liar = create_liar [
    function_name: 'connect'
    yields_as_flow: [
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

