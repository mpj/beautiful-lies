var expectation = {
  if_function:  'connect',
  with_arguments: [ 'bajs' ],
  result: RESULT,
  callback_1: CALLBACK_SPEC
};

var callback_spec = {
  in_order: [{
    argument_1: RESULT,
    argument_2: RESULT
  }],
  as_flow: [{
    argument_1: RESULT,
    argument_2: RESULT
  }]
}

var result = {
  object: {},
  object_lies: EXPECTATION_ARRAY
};

// ====================================


var lie = {
  if_function:  'connect',
  first_time: {
    with_arguments: [ 'bajs' ],
    result: RESULT,
    argument_1: RESULT,
    argument_2: RESULT
  }
};


var result = {
  object: {},
  object_lies: LIE_ARRAY
};

// ====================================

var expectation = {
  if_function:  'connect',
  with_arguments: [ 'bajs' ],
  first_outcome: OUTCOME
};

var outcome = {
  return_value: { status: 'open' },
  on_return_value: EXPECTATION_ARRAY
  first_callback: OUTCOME
  second_callback: OUTCOME
}

var callback_spec = {

  in_order: [{
    argument_1: RESULT,
    argument_2: RESULT
  }],
  as_flow: [{
    argument_1: RESULT,
    argument_2: RESULT
  }]
}

var result = {
  object: {},
  object_lies: EXPECTATION_ARRAY
};