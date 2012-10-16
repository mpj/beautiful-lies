
Library.artists = create_liar({
  function_name: 'snapshot',
  with_arguments: [0, 50],
  returns: {
    on_value: {
      function_name: 'done',
      yields: {
        on_argument_1st: {
          function_name: 'loadAll',
          with_arguments: [ 'name' ]
          returns: {
            on_value: {
              function_name: 'done',
              yields: {
                argument_1st: [
                  { name: "Lady Gaga" },
                  { name: "Rick Astley" }
                ]
              }
            }
          }
        }
      }
    }
  }
}

// Plugin
function promise_done_yields(yield_spec, parent) {
  parent.returns = {
    on_value: {
      function_name: 'done',
      yields: yield_spec
    }
  }
}

Library.artists = create_liar({
  function_name: 'snapshot',
  with_arguments: [0, 50],
  promise_done_yields: {
    on_argument_1st: {
      function_name: 'loadAll',
      with_arguments: [ 'name' ]
      promise_done_yields: {
        argument_1st: [
          { name: "Lady Gaga" },
          { name: "Rick Astley" }
        ]
      }
    }
  }
}



