chai        = require 'chai'
should      = chai.should()
expect      = chai.expect

lies        = require '../src/beautiful-lies'
lie  = lies.lie

describe 'lie', ->

  it 'creates fake function', ->
    meow = lie
      returns:
        value: 'Meeeeow!'
    meow().should.equal 'Meeeeow!'

  it 'works with multiple set of expectations', ->

    imitator = lie [
      {
        arguments: [ 'cat' ]
        returns:
          value: 'Meow!'
      },{
        arguments: [ 'dog' ]
        returns:
          value: 'Woof!'
      }
    ]

    imitator('cat').should.equal('Meow!')
    imitator('dog').should.equal('Woof!')


