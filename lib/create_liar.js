// Beautiful Lies
// version: 0.2.1
// author: Mattias Petter Johansson
// license: MIT
(function() {
  var args_as_array, arrays_equal, callback_arguments_array, create_liar, filter_on_args, filter_on_function, find_function, generateHandler, injectLies, injectPlugins, inject_and_return, is_function, remove_functions, run_callback, run_callbacks, run_delayed,
    __slice = [].slice;

  create_liar = function(lies) {
    return injectLies({}, lies);
  };

  create_liar.plugins = require('./plugins');

  injectLies = function(liar, lies) {
    var lie, _i, _len;
    if (!Array.isArray(lies)) {
      throw new Error("lies must be an array.");
    }
    for (_i = 0, _len = lies.length; _i < _len; _i++) {
      lie = lies[_i];
      if (!(lie.function_name != null)) {
        throw new Error('lies must have property "function_name"');
      }
      if (typeof lie.function_name !== 'string') {
        throw new Error('function_name must be a string.');
      }
      injectPlugins(lie);
      liar[lie.function_name] = generateHandler(lie.function_name, lies);
    }
    return liar;
  };

  injectPlugins = function(lie) {
    var generated, key, value, _results;
    _results = [];
    for (key in lie) {
      value = lie[key];
      if (create_liar.plugins[key]) {
        delete lie[key];
        generated = create_liar.plugins[key](value);
        _results.push((function() {
          var _results1;
          _results1 = [];
          for (key in generated) {
            value = generated[key];
            _results1.push(lie[key] = generated[key]);
          }
          return _results1;
        })());
      } else {
        _results.push(void 0);
      }
    }
    return _results;
  };

  generateHandler = function(function_name, lies) {
    var handler;
    handler = function() {
      var lie, lies_matching_args, lies_matching_function, message, _i, _len;
      lies_matching_function = filter_on_function(lies, function_name);
      if (lies_matching_function.length === 1 && !(lies_matching_function[0]["arguments"] != null)) {
        lie = lies_matching_function[0];
      } else {
        lies_matching_args = filter_on_args(lies_matching_function, arguments);
        lie = lies_matching_args[0];
        if (!lie) {
          message = "funkyFunction called with unexpected arguments. " + "Actual: " + args_as_array(arguments).join(', ');
          for (_i = 0, _len = lies_matching_function.length; _i < _len; _i++) {
            lie = lies_matching_function[_i];
            message += "Possible: " + args_as_array(lie["arguments"]).join(', ');
          }
          throw new Error(message);
        }
      }
      run_callbacks(lie, arguments);
      handler.times_called++;
      handler.call_arguments.push(args_as_array(arguments));
      if (lie.returns != null) {
        return inject_and_return(lie.returns);
      }
    };
    handler.times_called = 0;
    handler.call_arguments = [];
    handler.called_with = function() {
      var args, call, _i, _len, _ref;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      _ref = handler.call_arguments;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        call = _ref[_i];
        if (arrays_equal(call, args)) {
          return true;
        }
      }
      return false;
    };
    return handler;
  };

  inject_and_return = function(return_lie) {
    var _ref;
    if (!return_lie) {
      return null;
    }
    if (!(return_lie.value != null) && !(return_lie.on_value != null)) {
      throw new Error('returns object must have property "value" or "on_value"');
    }
    if ((_ref = return_lie.value) == null) {
      return_lie.value = {};
    }
    if (return_lie.on_value != null) {
      injectLies(return_lie.value, return_lie.on_value);
    }
    return return_lie.value;
  };

  filter_on_function = function(lies, function_name) {
    var lie, _i, _len, _results;
    _results = [];
    for (_i = 0, _len = lies.length; _i < _len; _i++) {
      lie = lies[_i];
      if (lie.function_name === function_name) {
        _results.push(lie);
      }
    }
    return _results;
  };

  filter_on_args = function(lies, args_obj) {
    var actual_args_cleaned, lie, matches_args, _i, _len, _results;
    actual_args_cleaned = remove_functions(args_obj);
    matches_args = function(lie) {
      var lie_args, _ref;
      lie_args = (_ref = lie["arguments"]) != null ? _ref : [];
      if (!Array.isArray(lie_args)) {
        throw new Error("arguments must be of type Array.");
      }
      return arrays_equal(lie_args, actual_args_cleaned);
    };
    _results = [];
    for (_i = 0, _len = lies.length; _i < _len; _i++) {
      lie = lies[_i];
      if (matches_args(lie)) {
        _results.push(lie);
      }
    }
    return _results;
  };

  run_callbacks = function(lie, arguments_obj) {
    var callback, m, y, _i, _len, _ref, _results;
    callback = find_function(arguments_obj);
    if (lie.run_callback) {
      if (!(lie.__calls != null)) {
        lie.__calls = 0;
      }
      y = lie.run_callback[lie.__calls++];
      if (!(y != null)) {
        m = ("" + lie.function_name + " was called " + lie.__calls + " times, ") + ("but only defined " + lie.run_callback.length + " run_callback.");
        throw new Error(m);
      }
      run_callback(y, callback);
    }
    if (lie.run_callback_flow) {
      _ref = lie.run_callback_flow;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        y = _ref[_i];
        _results.push(run_callback(y, callback));
      }
      return _results;
    }
  };

  run_callback = function(y, callback) {
    var callback_arguments, _ref;
    if (!callback) {
      return;
    }
    callback_arguments = callback_arguments_array(y);
    if ((_ref = y.delay) == null) {
      y.delay = 50;
    }
    return run_delayed(this, callback, callback_arguments, y.delay);
  };

  run_delayed = function(thisObj, fn, args, delay) {
    return setTimeout(function() {
      return fn.apply(thisObj, args);
    }, delay);
  };

  find_function = function(arguments_obj) {
    var arg, _i, _len;
    for (_i = 0, _len = arguments_obj.length; _i < _len; _i++) {
      arg = arguments_obj[_i];
      if (is_function(arg)) {
        return arg;
      }
    }
    return null;
  };

  callback_arguments_array = function(run_callback_spec) {
    var args, highest_index, i, index, match, property_name, _i;
    args = [];
    highest_index = 0;
    for (property_name in run_callback_spec) {
      match = /argument_(\d+)/.exec(property_name);
      if (match != null) {
        index = parseInt(match[1]) - 1;
        args[index] = inject_and_return(run_callback_spec[property_name]);
        if (index > highest_index) {
          highest_index = index;
        }
      }
    }
    for (i = _i = 0; 0 <= highest_index ? _i <= highest_index : _i >= highest_index; i = 0 <= highest_index ? ++_i : --_i) {
      if (!(args[i] != null)) {
        args[i] = null;
      }
    }
    if (args.length > 0) {
      return args;
    } else {
      return null;
    }
  };

  arrays_equal = function(a, b) {
    var i, item, _i, _len;
    if ((a != null) !== (b != null) || a.length !== b.length) {
      return false;
    }
    for (i = _i = 0, _len = a.length; _i < _len; i = ++_i) {
      item = a[i];
      if (item !== b[i]) {
        return false;
      }
    }
    return true;
  };

  remove_functions = function(arr) {
    var item, _i, _len, _results;
    _results = [];
    for (_i = 0, _len = arr.length; _i < _len; _i++) {
      item = arr[_i];
      if (!is_function(item)) {
        _results.push(item);
      }
    }
    return _results;
  };

  is_function = function(obj) {
    return (obj != null) && {}.toString.call(obj) === '[object Function]';
  };

  args_as_array = function(arguments_obj) {
    var arg, _i, _len, _results;
    if (!(arguments_obj != null)) {
      return [];
    }
    _results = [];
    for (_i = 0, _len = arguments_obj.length; _i < _len; _i++) {
      arg = arguments_obj[_i];
      _results.push(arg);
    }
    return _results;
  };

  module.exports = create_liar;

}).call(this);
