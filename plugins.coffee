plugins =

  callback_result: (obj) ->
    yields_in_order: [
      argument_2: obj
    ]

  on_callback_result: (obj) ->
    yields_in_order: [
      argument_2:
        on_value: obj
    ]

  callback_error_value: (obj) ->
    yields_in_order: [
      argument_1:
        value: obj
    ]

  promise_done: (obj) ->
    returns:
      on_value: [
        function_name: 'done'
        yields_in_order: [
          argument_1: obj
        ]
      ]

  on_promise_done: (obj) ->
    plugins.promise_done
      on_value: obj

  promise_done_value: (obj) ->
    plugins.promise_done
      value: obj

  promise_fail: (obj) ->
    returns:
      on_value: [
        function_name: 'fail'
        yields_in_order: [
          argument_1: obj
        ]
      ]

  promise_fail_value: (obj) ->
    plugins.promise_fail
      value: obj

module.exports = plugins