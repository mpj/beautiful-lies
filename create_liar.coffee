deepEquals = require './deep_equal.js'

create_liar = (spec) ->
  
  liar = {}
  
  # TODO: Check for function called existance
  if spec.function_called
    # TODO: Check for function called = string
    # TODO: check for with_arguments
    liar[spec.function_called] = (actual...) ->
      if spec.with_arguments
        expected = spec.with_arguments
        for e, i in expected
          if actual[i] isnt expected[i]
            throw new Error(
              "funkyFunction called with unexpected arguments. " +
              "Actual: " + actual + " " +
              "Expected: " + expected)

      spec.returns.value

  liar



isObject = (obj) ->
  obj and typeof(obj) is 'object' and !this.isArray(obj)

module.exports = create_liar