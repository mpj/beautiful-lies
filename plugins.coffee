module.exports =

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

