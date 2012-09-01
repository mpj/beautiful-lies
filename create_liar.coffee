

create_liar = (specs) ->  
  injectLies {}, specs

injectLies = (liar, specs) -> 
  for spec in specs
    # TODO: Check for function called existance
    if spec.function_called
      # TODO: Check for function called = string
      # TODO: check for with_arguments
      liar[spec.function_called] = 
        createFunction liar, spec.function_called, specs
        
  liar

createFunction = (liar, function_name, expectations) ->
  (actual...) ->

    matching_expectations = []
    for exp in expectations
      if exp.function_called is function_name
        expected = exp.with_arguments ? null
        if actual.length is 0 and not expected
          is_match = true
        else if expected
          is_match = true  
          for e, i in expected
            if actual[i] isnt expected[i]
              is_match = false
        
      matching_expectations.push exp if is_match

    spec = matching_expectations[0]
    if not spec
      throw new Error(
            "funkyFunction called with unexpected arguments. " +
            "Actual: " + actual + " " +
            "Expected: " + expected)
          
    if spec.returns.value
      if spec.returns.on_value
        injectLies spec.returns.value, spec.returns.on_value
      spec.returns.value
  


module.exports = create_liar