module.exports =

  callback_result: (obj) ->
    yields_in_order: [
      argument_2: obj
    ]

  callback_error: (obj) ->
    yields_in_order: [
      argument_1:
        value: obj
    ]

  promise_done: (obj) ->
    returns:
      on_value: [
        function_name: 'done'
        yields_in_order: [
          argument_1:
            value: obj
        ]
      ]

  promise_fail: (obj) ->
    returns:
      on_value: [
        function_name: 'fail'
        yields_in_order: [
          argument_1:
            value: obj
        ]
      ]

