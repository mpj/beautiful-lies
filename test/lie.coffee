chai        = require 'chai'
should      = chai.should()
expect      = chai.expect

lies        = require '../src/beautiful-lies'
lie  = lies.lie

describe 'lie', ->

  it 'should create fake function', ->
    meow = lie
      returns:
        value: 'Meeeeow!'
    meow().should.equal 'Meeeeow!'


