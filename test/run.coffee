chai        = require 'chai'
should      = chai.should()
expect      = chai.expect

lies        = require '../src/beautiful-lies'
lie         = lies.lie
createLiar  = lies.createLiar

describe 'run_function', ->

  bamseBear = null

  describe 'when using createLiar', ->

    beforeEach ->
      bamseBear = createLiar
        function_name: 'eatHoney'
        run_function: ->
          this.isStrong = true

      bamseBear.isStrong = false

    it 'set isStrong when calling', ->
      bamseBear.eatHoney()
      bamseBear.isStrong.should.equal true

    it 'should not have set before', ->
      bamseBear.isStrong.should.equal false