macros =

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
        returns: self: true
      }, {
        # Implicit fail that does nothing.
        function_name: 'fail'
        returns: self: true
      }]

  on_promise_done: (obj) ->
    # FIXME Deprecate this in next major
    console.warn 'on_promise_done is deprecated, use on_promise_done_value'
    promise_done:
      on_value: obj

  on_promise_done_value: (obj) ->
    promise_done:
      on_value: obj

  promise_done_value: (obj) ->
    promise_done:
      value: obj

  promise_fail: (obj) ->
    returns:
      on_value: [{
        function_name: 'fail'
        run_callback: [
          argument_1: obj
        ]
        returns: self: true
      },{
        # Implicit done that does nothing.
        function_name: 'done'
        returns: self: true
      }]

  promise_fail_value: (obj) ->
    promise_fail:
      value: obj

module.exports = macros