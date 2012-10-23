create_liar = (lies) ->
  injectLies {}, lies

# Inject built-in plugins
create_liar.plugins = require './plugins'

injectLies = (liar, lies) ->
  if not Array.isArray lies
    throw new Error "lies must be an array."
  for lie in lies
    if not lie.function_name?
      throw new Error 'lies must have property "function_name"'
    if typeof lie.function_name isnt 'string'
      throw new Error 'function_name must be a string.'

    injectPlugins lie

    liar[lie.function_name] =
      generateHandler lie.function_name, lies
  liar

injectPlugins = (lie) ->
  for key, value of lie
    if create_liar.plugins[key]
      delete lie[key]
      generated = create_liar.plugins[key](value)
      for key, value of generated
        lie[key] = generated[key]

generateHandler = (function_name, lies) ->


  handler = () ->

    lies_matching_function = filter_on_function lies, function_name

    if lies_matching_function.length is 1 and not lies_matching_function[0].arguments?
      lie = lies_matching_function[0]
    else
      lies_matching_args = filter_on_args lies_matching_function, arguments
      lie = lies_matching_args[0]
      if not lie
        message = "funkyFunction called with unexpected arguments. " +
                  "Actual: " + args_as_array(arguments).join(', ')
        for lie in lies_matching_function
          message += "Possible: " + args_as_array(lie.arguments).join(', ')
        throw new Error(message)

    run_callbacks lie, arguments

    handler.times_called++
    handler.call_arguments.push(args_as_array(arguments))

    if lie.returns?
      inject_and_return lie.returns

  handler.times_called = 0
  handler.call_arguments = []
  handler.called_with = (args...) ->
    for call in handler.call_arguments
      if arrays_equal call, args
        return true
    return false
  return handler

inject_and_return = (return_lie) ->
  return null if not return_lie
  if not return_lie.value? and not return_lie.on_value?
    throw new Error('returns object must have property "value" or "on_value"')

  return_lie.value ?= {}
  if return_lie.on_value?
    injectLies return_lie.value, return_lie.on_value
  return_lie.value

filter_on_function = (lies, function_name) ->
  lie for lie in lies when lie.function_name is function_name

filter_on_args = (lies, args_obj) ->
  actual_args_cleaned = remove_functions(args_obj)
  matches_args = (lie) ->
    lie_args = lie.arguments ? []
    if not Array.isArray lie_args
      throw new Error "arguments must be of type Array."
    arrays_equal lie_args, actual_args_cleaned

  lie for lie in lies when matches_args(lie)



run_callbacks = (lie, arguments_obj) ->
  callback = find_function arguments_obj

  if lie.yields_in_order
    yio = lie.yields_in_order
    yio.__calls = 0 if not yio.__calls?
    y = yio[yio.__calls++]
    if not y?
      m = "#{lie.function_name} was called #{yio.__calls} times, " +
          "but only defined #{yio.length} yields_in_order."
      throw new Error(m)
    run_yield y, callback


  if lie.yields_as_flow
    run_yield y, callback for y in lie.yields_as_flow

run_yield = (y, callback) ->
  return if not callback # Sometimes, callback are not provided
                         # but we generally want to behave as
                         # if they we're executed.
                         # TODO: Add log feedback when this happens.
  callback_arguments = callback_arguments_array y

  y.delay ?= 50
  run_delayed this, callback, callback_arguments, y.delay


run_delayed = (thisObj, fn, args, delay) ->
  setTimeout () ->
    fn.apply thisObj, args
  , delay


find_function = (arguments_obj) ->
  for arg in arguments_obj
    return arg if is_function(arg)
  null

callback_arguments_array = (yield_spec) ->
  args = []
  highest_index = 0

  # TODO perhaps use the funky coffescript Comprehensions here
  # to create a matches array
  for property_name of yield_spec
    match = /argument_(\d+)/.exec property_name
    if match?
      index = parseInt(match[1]) - 1
      args[index] = inject_and_return(yield_spec[property_name])
      highest_index = index if index > highest_index

  # fill em up
  for i in [0..highest_index]
    args[i] = null if not args[i]?
  if args.length > 0 then args else null

arrays_equal = (a, b) ->
  return false if a? isnt b? or a.length isnt b.length
  for item, i in a
    return false if item isnt b[i]
  true

remove_functions = (arr) ->
  # Returns a copy of arr, with functions removed.
  item for item in arr when not is_function(item)

is_function = (obj) ->
  obj? and {}.toString.call(obj) is '[object Function]'

args_as_array = (arguments_obj) ->
  # Convert that pesky function arguments object
  # to a normal array.
  if not arguments_obj?
    return []
  arg for arg in arguments_obj



module.exports = create_liar