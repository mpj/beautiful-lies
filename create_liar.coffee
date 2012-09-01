

create_liar = (lies) ->  
  injectLies {}, lies

injectLies = (liar, lies) -> 
  for lie in lies
    liar[lie.function_name] = 
      generateHandler lie.function_name, lies
  liar

generateHandler = (function_name, lies) ->
  () ->

    matching_lies = filter lies, function_name, arguments
    lie = matching_lies[0]
    if not lie
      throw new Error(
        "funkyFunction called with unexpected arguments. " +
        "Actual: " + arguments_to_array(arguments).join(', '))
          
    run_callback lie, arguments

    r = lie.returns ? null
    if r and r.value
      if r.on_value
        injectLies r.value, r.on_value
      r.value


filter = (lies, function_name, arguments_obj) ->
  matching_lies = []
  for lie in lies
    if function_name is lie.function_name
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
      callback.apply this, callback_arguments

find_function = (arguments_obj) ->
  for arg in arguments_obj
    return arg if is_function(arg)
  null

callback_arguments_array = (lie) ->
  args = []
  highest_index = 0
  for property of lie
    match = /callback_argument_(\d+)/.exec property
    if match?
      index = parseInt(match[1])-1
      args[index] = lie[property].value
      highest_index = index if index > highest_index

  # fill em up
  for i in [0..highest_index]
    args[i] = null if not args[i]?

  return null if args.length is 0

  args

arrays_equal = (a, b) ->
  for item, i in a
    return false if item isnt b[i]
  true

remove_functions = (arr) ->
  # Returns a copy of the array, with functions removed.
  item for item in arr when not is_function(item)

is_function = (obj) ->
  return false if not obj?
  (({}).toString).call(obj) is '[object Function]'

arguments_to_array = (arguments_obj) ->
  # Convert that pesky function arguments object
  # to a normal array.
  arg for arg in arguments_obj



module.exports = create_liar