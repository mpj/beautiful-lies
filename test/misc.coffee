chai        = require 'chai'
should      = chai.should()
expect      = chai.expect
create_liar = require '../create_liar'

# TODO
# "Value should be implicit if on_value defined" breaks if you change to yields_in_order
# yield
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
# Test duplication!
# Implicit arrays
# plugins
  # yields_result plugin
  # yeilds_error
  # promise plugin


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

