deepEquals = require './deep_equal.js'

create_liar = (spec) ->
  
  liar = {}

  # console.log spec
  
  # TODO: Check for function called existance
  if spec.function_called
    # TODO: Check for function called = string
    # TODO: check for with_arguments
    liar[spec.function_called] = ->
      if spec.with_arguments
        actual = arguments
        expected = spec.with_arguments
        for e, i in expected
          console.log "comparing", actual[i],expected[i]
          if actual[i] isnt expected[i]
            throw "funkyFunction called with unexpected arguments: 'oranges'. 
            Expected: 'apples'" 


      spec.returns.value



  liar






isObject = (obj) ->
  obj and typeof(obj) is 'object' and !this.isArray(obj)

module.exports = create_liar