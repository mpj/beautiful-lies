// Beautiful Lies
// version: 1.0.8
// author: Mattias Petter Johansson <mpj@mpj.me> http://mpj.me
// license: MIT
(function() {
  var args_as_array, arrays_equal, create_liar, filter_on_args, filter_on_function, find_function, generateHandler, injectLies, injectPlugins, is_function, lie, remove_functions, run_delayed,
    __slice = [].slice;

  create_liar = function(lies) {
    return injectLies({}, lies);
  };

  create_liar.plugins = require('./plugins');

  lie = function(lies) {
    var temp_obj;
    if (!Array.isArray(lies)) {
      lies = [lies];
    }
    lies.forEach(function(lie) {
      return lie.function_name = 'untitled_function';
    });
    temp_obj = create_liar(lies);
    return temp_obj['untitled_function'];
  };

  injectLies = function(liar, lies) {
    var _i, _len;
    if (!Array.isArray(lies)) {
      lies = [lies];
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
      lie.host = liar;
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

  generateHandler = function(function_name, all_expectations) {
    var handler;
    handler = function() {
      var expectation, expectations_matching, handler_callback, lies_matching_args, m, match, message, process_result_spec, process_single_callback_spec, s, _base, _i, _j, _len, _len1, _ref, _ref1, _ref2;
      expectation = null;
      expectations_matching = filter_on_function(all_expectations, function_name);
      if (expectations_matching.length === 1 && !(expectations_matching[0]["arguments"] != null)) {
        expectation = expectations_matching[0];
      } else {
        lies_matching_args = filter_on_args(expectations_matching, arguments);
        expectation = lies_matching_args[0];
      }
      if (!expectation) {
        message = "funkyFunction called with unexpected arguments. " + "Actual: " + args_as_array(arguments).join(', ');
        for (_i = 0, _len = expectations_matching.length; _i < _len; _i++) {
          match = expectations_matching[_i];
          message += "Possible: " + args_as_array(match["arguments"]).join(', ');
        }
        throw new Error(message);
      }
      if (expectation.run_function) {
        expectation.run_function.bind(expectation.host)();
      }
      process_result_spec = function(result_spec) {
        var _ref;
        if (!result_spec) {
          return null;
        }
        if (typeof result_spec.value === 'undefined' && typeof result_spec.on_value === 'undefined' && !result_spec.self) {
          throw new Error('returns object must have property "value" or "on_value" or "self: true"');
        }
        if (typeof result_spec.on_value !== 'undefined') {
          if ((_ref = result_spec.value) == null) {
            result_spec.value = {};
          }
          injectLies(result_spec.value, result_spec.on_value);
        }
        if (result_spec.self === true) {
          return expectation.host;
        } else {
          return result_spec.value;
        }
      };
      handler_callback = find_function(arguments);
      if ((_ref = (_base = expectation.host).__callbacks) == null) {
        _base.__callbacks = [];
      }
      expectation.host.__callbacks.push({
        function_name: expectation.function_name,
        "arguments": remove_functions(arguments),
        function_ref: handler_callback
      });
      process_single_callback_spec = function(callback_spec) {
        var callback_arguments, candidates, fn, highest_index, i, index, property_name, _j, _ref1;
        if (callback_spec.of) {
          if (typeof callback_spec.of !== 'object') {
            throw new Error('run_callback.of property was set to "' + callback_spec.of + '" - must be an object.');
          }
          if (callback_spec.of["arguments"] && !Array.isArray(callback_spec.of["arguments"])) {
            callback_spec.of["arguments"] = [callback_spec.of["arguments"]];
          }
          candidates = expectation.host.__callbacks.filter(function(c) {
            return c.function_name === callback_spec.of.function_name && (!(callback_spec.of["arguments"] != null) || arrays_equal(callback_spec.of["arguments"], c["arguments"]));
          });
          if (candidates.length === 0) {
            throw new Error('Tried to run callback provided to ' + callback_spec.of.function_name + ' along ' + 'with arguments [ ' + callback_spec.of["arguments"].join(', ') + ' ], ' + 'but didn\'t find any. Did you misspell ' + 'function_name or arguments, or perhaps the callback was never passed to ' + callback_spec.of.function_name + '?');
          }
          if (candidates.length > 1 && !(callback_spec.of["arguments"] != null)) {
            throw new Error('Tried to run callback provided to ' + callback_spec.of.function_name + ', but I had multiple choices and could not guess which one was right. ' + 'You need to provide run_callback.of.arguments.');
          }
          fn = candidates[0].function_ref;
        } else {
          fn = handler_callback;
        }
        if (!fn) {
          return;
        }
        callback_arguments = [];
        highest_index = 0;
        if (!callback_spec.no_arguments) {
          for (property_name in callback_spec) {
            match = /argument_(\d+)/.exec(property_name);
            if (match != null) {
              index = parseInt(match[1]) - 1;
              callback_arguments[index] = process_result_spec(callback_spec[property_name]);
              if (index > highest_index) {
                highest_index = index;
              }
            }
          }
          for (i = _j = 0; 0 <= highest_index ? _j <= highest_index : _j >= highest_index; i = 0 <= highest_index ? ++_j : --_j) {
            if (!(callback_arguments[i] != null)) {
              callback_arguments[i] = null;
            }
          }
          if (callback_arguments.length > 0) {
            callback_arguments;

          } else {
            null;
          }
        }
        return run_delayed(this, fn, callback_arguments, (_ref1 = callback_spec.delay) != null ? _ref1 : callback_spec.delay = 50);
      };
      if (expectation.run_callback) {
        if (!Array.isArray(expectation.run_callback)) {
          expectation.run_callback = [expectation.run_callback];
        }
        if (expectation.run_callback.length === 1) {
          s = expectation.run_callback[0];
        } else {
          if ((_ref1 = expectation.__calls) == null) {
            expectation.__calls = 0;
          }
          s = expectation.run_callback[expectation.__calls++];
        }
        if (!(s != null)) {
          m = ("" + expectation.function_name + " was called " + expectation.__calls + " times, ") + ("but only defined " + expectation.run_callback.length + " run_callback.");
          throw new Error(m);
        }
        process_single_callback_spec(s);
      } else if (expectation.run_callback_flow) {
        _ref2 = expectation.run_callback_flow;
        for (_j = 0, _len1 = _ref2.length; _j < _len1; _j++) {
          s = _ref2[_j];
          process_single_callback_spec(s);
        }
      }
      handler.times_called++;
      handler.call_arguments.push(args_as_array(arguments));
      if (expectation.returns != null) {
        return process_result_spec(expectation.returns);
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

  filter_on_function = function(lies, function_name) {
    var _i, _len, _results;
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
    var actual_args_cleaned, matches_args, _i, _len, _results;
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

  remove_functions = function(object) {
    var item, _i, _len, _results;
    _results = [];
    for (_i = 0, _len = object.length; _i < _len; _i++) {
      item = object[_i];
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

  module.exports.createLiar = create_liar;

  module.exports.lie = lie;

}).call(this);
