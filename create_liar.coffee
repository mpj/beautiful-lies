deepEquals = require './deep_equal.js'

create_liar = (spec) ->
  
  liar = {}

  # console.log spec
  
  # TODO: Check for function called existance
  if spec.function_called
    # TODO: Check for function called = string
    # TODO: check for with_arguments
    liar[spec.function_called] = ->
      spec.returns.value

  liar






isObject = (obj) ->
  obj and typeof(obj) is 'object' and !this.isArray(obj)

module.exports = create_liar