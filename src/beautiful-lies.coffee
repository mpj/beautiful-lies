
macros = require './macros'

lie = (expectations) ->

  if not expectations?
    Object.prototype.lie = lie
    return

  expectations = [ expectations ] if not Array.isArray expectations

  for expectation in expectations
    preprocessExpectation expectation
    assignHandler this, expectation.function_name

  this.__expectations ?= []
  this.__expectations.push e for e in expectations
  this

preprocessExpectation = (expectation) ->

  injectMacros expectation

  if not expectation.function_name?
    throw new Error 'expectation must have property "function_name"'
  if typeof expectation.function_name isnt 'string'
    throw new Error 'function_name must be a string.'


# Macros (formerly called plugins) are functions that
# generate Beautiful Lies DSL, the are used to metaprogram
# mocks to reduce duplication.
injectMacros = (expectation) ->
  for own key, value of expectation
    if macros[key]
      delete expectation[key]
      generated = macros[key](value)
      injectMacros generated
      for own key, value of generated
        expectation[key] = generated[key]

assignHandler = (host, function_name) ->

  handler = () ->

    # 1. Find the expectation that matches the handler call.
    expectation = null
    expectations_matching = filter_on_function host.__expectations, function_name
    if expectations_matching.length is 1 and not expectations_matching[0].arguments?
      expectation = expectations_matching[0]
    else
      expectations_matching_args = filter_on_args expectations_matching, arguments
      expectation = expectations_matching_args[0]
      # TODO: What if we get multiple matches?

    # 2. Throw an error if we did not find an expectation
    # matching the handler call.
    if not expectation
      message = "#{ function_name } called with unexpected arguments. " +
                "Actual: " + args_as_array(arguments).join(', ')
      for match in expectations_matching
        message += "Possible: " + args_as_array(match.arguments).join(', ')
      throw new Error(message)

    # 3. If the expectation specifies a run_function,
    # execute it.
    # TODO: This return value should probably, well, return.
    # It would also be nice if it got the proper arguments too.
    if expectation.run_function
      expectation.run_function.bind(host)()

    # 4. Prepare a function for processing result specs.
    process_result_spec = (result_spec) ->
      return null if not result_spec
      if  typeof result_spec.value is 'undefined' and
          typeof result_spec.on_value is 'undefined' and
          !result_spec.self
        throw new Error('returns object must have property "value" or "on_value" or "self: true"')

      if typeof result_spec.on_value isnt 'undefined'

        # If we have expectations on_value, but no value,
        # we implicitly assume that the user means an empty object.
        result_spec.value ?= {}

        result_spec.value.lie result_spec.on_value

      if result_spec.self is true
        return host
      else
        result_spec.value

    # 5. Trigger callbacks

    # 5.1. Store a reference to the callback provided to the
    # handler. This is used by the "of" command to call the
    # callbacks given to other functions.
    handler_callback = find_function(arguments)
    host.__callbacks ?= []
    host.__callbacks.push
      function_name: expectation.function_name
      arguments: remove_functions(arguments)
      function_ref: handler_callback

    # 5.2 Define a function that triggers a callback according
    # to a single callback specification (an expectation might define
    # multiple callback specifications)
    process_single_callback_spec = (callback_spec) ->

      # 5.2.1 If the "property_xxxxxx" is set on the callback
      # specification, that means that we want the result
      # specification passed to it to be set to that property on
      # the host object.
      assignPropertyWithName = null
      assignPropertyWithResultSpec = null
      for property_name of callback_spec
        match = /property_(.+)/.exec property_name
        if match?
          assignPropertyWithName = match[1]
          assignPropertyWithResultSpec = callback_spec[property_name]

      if assignPropertyWithName
        # Create a function that assigns the property value,
        # and assign it as the callback to be used.
        fn = (propValue) -> host[assignPropertyWithName] = propValue
        # We then re-write the callback spec so that the result
        # spec originally passed to property_xxxx is passed to
        # argument_1, which will make it pass to our newly
        # created function.
        callback_spec.argument_1 = assignPropertyWithResultSpec
        # TODO The above feels slighly weird.. Perhaps it could be
        # made in a better way.

      # 5.2.2 If the "of" property is set on the callback specification,
      # that means that we want to call back to the callback of
      # ANOTHER function, instead of any callback provided to the
      # handler. This is used to mock out stuff like
      # addEventListener(eventName, callback)
      else if callback_spec.of

        if typeof callback_spec.of isnt 'object'
          throw new Error 'run_callback.of property was set to "' + callback_spec.of + '" - must be an object.'

        # arguments property should be an implicit array.
        if callback_spec.of.arguments and not Array.isArray(callback_spec.of.arguments)
          callback_spec.of.arguments = [ callback_spec.of.arguments ]

        candidates = host.__callbacks.filter (c) ->
          c.function_name is callback_spec.of.function_name and ( !callback_spec.of.arguments? or arrays_equal(callback_spec.of.arguments, c.arguments ) )

        if candidates.length is 0
          throw new Error 'Tried to run callback provided to ' + callback_spec.of.function_name + ' along ' +
            'with arguments [ ' + callback_spec.of.arguments.join(', ') + ' ], ' +
            'but didn\'t find any. Did you misspell ' +
            'function_name or arguments, or perhaps the callback was never passed to ' +
            callback_spec.of.function_name + '?'

        if candidates.length > 1 and not callback_spec.of.arguments?
          throw new Error 'Tried to run callback provided to ' + callback_spec.of.function_name +
          ', but I had multiple choices and could not guess which one was right. ' +
          'You need to provide run_callback.of.arguments.'

        fn = candidates[0].function_ref
      else
        fn = handler_callback

      return if not fn # Sometimes, callback are not provided
                       # but we generally want to behave as
                       # if they we're executed.

      # Construct the actual objects to send to the callback
      callback_arguments = []
      highest_index = 0

      unless callback_spec.no_arguments
        # TODO perhaps use the funky coffescript Comprehensions here
        # to create a matches array
        for property_name of callback_spec
          match = /argument_(\d+)/.exec property_name
          if match?
            index = parseInt(match[1]) - 1
            callback_arguments[index] = process_result_spec callback_spec[property_name]
            highest_index = index if index > highest_index

        # fill em up
        for i in [0..highest_index]
          callback_arguments[i] = null if not callback_arguments[i]?
        if callback_arguments.length > 0 then callback_arguments else null
        # FIXME: The above line is unnecessary for any tests to pass.
        # Investigate.


      # Finally, run the callback!
      run_delayed host, fn, callback_arguments, callback_spec.delay ?= 50

    if expectation.run_callback

      # This expectation calls it's callback in an *ordered* manner
      # (as opposed to a *flowing* manner). This means that the first time
      # the function is called, the first callback spec is executed, the
      # second call the second callback spec, and so on ...

      # run_callback might be a single object or an array.
      if not Array.isArray expectation.run_callback
        expectation.run_callback = [ expectation.run_callback ]

      if expectation.run_callback.length is 1
        s = expectation.run_callback[0]
      else
        expectation.__calls ?= 0
        s = expectation.run_callback[expectation.__calls++]

      if not s?
        m = "#{expectation.function_name} was called #{expectation.__calls} times, " +
            "but only defined #{expectation.run_callback.length} run_callback."
        throw new Error(m)

      process_single_callback_spec s

    else if expectation.run_callback_flow
      # This expectation calls it's callback in a *flow*, i.e. executes all it's
      # callback specs immideately, but in a fast flow.
      for s in expectation.run_callback_flow
        process_single_callback_spec s

    handler.times_called++
    handler.call_arguments.push(args_as_array(arguments))

    if expectation.returns?
      process_result_spec expectation.returns

    # END handler

  handler.times_called = 0
  handler.call_arguments = []
  handler.called_with = (args...) ->
    for call in handler.call_arguments
      return true if arrays_equal call, args
    false

  host[function_name] = handler

handle_function_call = (host, handler, function_name) ->
  # TODO Can function name be inferred with callee?


filter_on_function = (expectations, function_name) ->
  e for e in expectations when e.function_name is function_name

filter_on_args = (expectations, args_obj) ->

  result = -> e for e in expectations when matches_args_obj(e)

  matches_args_obj = (exp) ->
    exp_args = exp.arguments ? []
    if not Array.isArray exp_args
      throw new Error "arguments must be of type Array."
    arrays_equal exp_args, actual_args_cleaned

  actual_args_cleaned = remove_functions args_obj

  result()

run_delayed = (thisObj, fn, args, delay) ->
  setTimeout (-> fn.apply thisObj, args ), delay

find_function = (arguments_obj) ->
  for arg in arguments_obj
    return arg if is_function(arg)
  null

arrays_equal = (a, b) ->
  return false if a? isnt b? or a.length isnt b.length
  for item, i in a
    return false if item isnt b[i]
  true

remove_functions = (object) ->
  # Returns a copy of object (which can be an array or
  # arguments object), with functions removed.
  item for item in object when not is_function(item)

is_function = (obj) -> obj? and {}.toString.call(obj) is '[object Function]'

args_as_array = (arguments_obj) ->
  # Convert that pesky function arguments object
  # to a normal array.
  return [] if not arguments_obj?
  arg for arg in arguments_obj

module.exports = {
  lie: lie
  macros: macros
}