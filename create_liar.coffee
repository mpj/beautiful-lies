

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
          
    r = lie.returns
    if r.value
      if r.on_value
        injectLies r.value, r.on_value
      r.value

filter = (lies, function_name, arguments_obj) ->
  matching_lies = []
  for lie in lies
    if function_name is lie.function_name
      arguments_arr = arguments_to_array arguments_obj 
      if arrays_equal arguments_arr, lie.arguments ? []
        matching_lies.push lie
  matching_lies

arguments_to_array = (arguments_obj) ->
  # Convert that pesky function arguments object
  # to a normal array
  arg for arg in arguments_obj


arrays_equal = (a, b) ->
  for item, i in a
    return false if item isnt b[i]
  true



module.exports = create_liar