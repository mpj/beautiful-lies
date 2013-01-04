plugins =

  callback_result: (obj) ->
    run_callback: [
      argument_2: obj
    ]

  on_callback_result: (obj) ->
    run_callback: [
      argument_2:
        on_value: obj
    ]

  callback_error_value: (obj) ->
    run_callback: [
      argument_1:
        value: obj
    ]

  promise_done: (result_spec) ->
    returns:
      on_value: [{
        function_name: 'done'
        run_callback: [
          argument_1: result_spec
        ]
      }, {
        # Implicit fail that does nothing.
        function_name: 'fail'
      }]

  on_promise_done: (obj) ->
    plugins.promise_done
      on_value: obj

  promise_done_value: (obj) ->
    plugins.promise_done
      value: obj

  promise_fail: (obj) ->
    returns:
      on_value: [{
        function_name: 'fail'
        run_callback: [
          argument_1: obj
        ]
      },{
        # Implicit done that does nothing.
        function_name: 'done'
      }]

  promise_fail_value: (obj) ->
    plugins.promise_fail
      value: obj

module.exports = plugins