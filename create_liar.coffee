

create_liar = (lies) ->  
  injectLies {}, lies

injectLies = (liar, lies) -> 
  if not Array.isArray lies
    throw new Error "lies must be an array."
  for lie in lies
    liar[lie.function_name] = 
      generateHandler lie.function_name, lies
  liar

generateHandler = (function_name, lies) -> () ->
  matching_lies = filter lies, function_name, arguments
  lie = matching_lies[0]
  if not lie
    throw new Error(
      "funkyFunction called with unexpected arguments. " +
      "Actual: " + arguments_to_array(arguments).join(', '))
        
  run_callback lie, arguments

  if lie.returns?
    inject_and_return lie.returns 

inject_and_return = (return_lie) ->
  return null if not return_lie
  if not return_lie.value? 
    throw new Error 'return statement must have property "value"'
  if return_lie.on_value?
    injectLies return_lie.value, return_lie.on_value
  return_lie.value

filter = (lies, function_name, arguments_obj) ->
  matching_lies = []
  for lie in lies
    if function_name is lie.function_name
      # TODO can these two lines merge?
      arguments_arr = arguments_to_array arguments_obj
      arguments_arr = remove_functions arguments_arr 
      if arrays_equal arguments_arr, lie.arguments ? []
        matching_lies.push lie
  matching_lies



run_callback = (lie, arguments_obj) ->
  callback_arguments = callback_arguments_array lie
  if callback_arguments
    callback = find_function arguments_obj
    if callback
      setTimeout(
        callback.apply this, callback_arguments
      , 50)

find_function = (arguments_obj) ->
  for arg in arguments_obj
    return arg if is_function(arg)
  null

callback_arguments_array = (lie) ->
  args = []
  highest_index = 0
  # TODO perhaps use the funky coffescript Comprehensions here
  # to create a matches array

  for property_name of lie
    match = /callback_argument_(\d+)/.exec property_name
    if match?
      index = parseInt(match[1]) - 1
      args[index] = inject_and_return(lie[property_name])
      highest_index = index if index > highest_index

  # fill em up
  for i in [0..highest_index]
    args[i] = null if not args[i]?

  if args.length > 0 then args else null

arrays_equal = (a, b) ->
  for item, i in a
    return false if item isnt b[i]
  true

remove_functions = (arr) ->
  # Returns a copy of the array, with functions removed.
  item for item in arr when not is_function(item)

is_function = (obj) ->
  obj? and {}.toString.call(obj) is '[object Function]'

arguments_to_array = (arguments_obj) ->
  # Convert that pesky function arguments object
  # to a normal array.
  arg for arg in arguments_obj



module.exports = create_liar