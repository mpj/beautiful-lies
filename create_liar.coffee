

create_liar = (spec) ->  
  injectLies {}, spec

injectLies = (liar, spec) ->
  # TODO: Check for function called existance
  console.log "spec", spec
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

      if spec.returns.value
        if spec.returns.on_value
          injectLies spec.returns.value, spec.returns.on_value
        spec.returns.value

      
  liar




module.exports = create_liar