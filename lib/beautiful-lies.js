(function() {
  var ANYTHING, args_as_array, argument_arrays_equal, assignHandler, deepEquals, filter_on_args, filter_on_function, find_function, handle_function_call, injectMacros, isPlainObject, isUndefined, is_function, lieFunc, macros, preprocessExpectation, remove_functions, run_delayed,
    __hasProp = {}.hasOwnProperty,
    __slice = [].slice;

  macros = require('./macros');

  isPlainObject = require('mout/lang/isPlainObject');

  deepEquals = require('mout/object/deepEquals');

  isUndefined = require('mout/lang/isUndefined');

  ANYTHING = {};

  lieFunc = function(expectations) {
    var e, expectation, _i, _j, _len, _len1, _ref;

    if (expectations == null) {
      Object.prototype.lie = lieFunc;
      return;
    }
    if (!Array.isArray(expectations)) {
      expectations = [expectations];
    }
    for (_i = 0, _len = expectations.length; _i < _len; _i++) {
      expectation = expectations[_i];
      preprocessExpectation(expectation);
      assignHandler(this, expectation.function_name);
    }
    if ((_ref = this.__expectations) == null) {
      this.__expectations = [];
    }
    for (_j = 0, _len1 = expectations.length; _j < _len1; _j++) {
      e = expectations[_j];
      this.__expectations.push(e);
    }
    return this;
  };

  preprocessExpectation = function(expectation) {
    injectMacros(expectation);
    if (expectation.function_name == null) {
      throw new Error('expectation must have property "function_name"');
    }
    if (typeof expectation.function_name !== 'string') {
      throw new Error('function_name must be a string.');
    }
  };

  injectMacros = function(expectation) {
    var generated, key, value, _results;

    _results = [];
    for (key in expectation) {
      if (!__hasProp.call(expectation, key)) continue;
      value = expectation[key];
      if (macros[key]) {
        delete expectation[key];
        generated = macros[key](value);
        injectMacros(generated);
        _results.push((function() {
          var _results1;

          _results1 = [];
          for (key in generated) {
            if (!__hasProp.call(generated, key)) continue;
            value = generated[key];
            _results1.push(expectation[key] = generated[key]);
          }
          return _results1;
        })());
      } else {
        _results.push(void 0);
      }
    }
    return _results;
  };

  assignHandler = function(host, function_name) {
    var handler;

    handler = function() {
      var args_as_string, expectation, handler_callback, m, match, matches_args, matches_name, message, process_result_spec, process_single_callback_spec, s, _i, _j, _len, _len1, _ref, _ref1, _ref2;

      matches_name = filter_on_function(host.__expectations, function_name);
      matches_args = filter_on_args(matches_name, arguments);
      expectation = matches_args[0];
      if (!expectation) {
        args_as_string = function(args) {
          var strings;

          strings = args_as_array(args).map(function(arg) {
            if (isPlainObject(arg)) {
              return JSON.stringify(arg);
            } else {
              return arg;
            }
          });
          return strings.join(', ');
        };
        message = ("" + function_name + " called with unexpected arguments. ") + "Actual: " + args_as_string(arguments);
        for (_i = 0, _len = matches_name.length; _i < _len; _i++) {
          match = matches_name[_i];
          message += "Possible: " + args_as_string(match["arguments"]);
        }
        throw new Error(message);
      }
      if (expectation.run_function) {
        expectation.run_function.bind(host)();
      }
      process_result_spec = function(result_spec) {
        var _ref;

        if (!result_spec) {
          return null;
        }
        if (isUndefined(result_spec.value) && isUndefined(result_spec.on_value) && !result_spec.self) {
          throw new Error('returns object must have property "value" or "on_value" or "self: true"');
        }
        if (!isUndefined(result_spec.on_value)) {
          if ((_ref = result_spec.value) == null) {
            result_spec.value = {};
          }
          result_spec.value.lie(result_spec.on_value);
        }
        if (result_spec.self === true) {
          return host;
        } else {
          return result_spec.value;
        }
      };
      handler_callback = find_function(arguments);
      if ((_ref = host.__callbacks) == null) {
        host.__callbacks = [];
      }
      host.__callbacks.push({
        function_name: expectation.function_name,
        "arguments": remove_functions(arguments),
        function_ref: handler_callback
      });
      process_single_callback_spec = function(callback_spec) {
        var assignPropertyWithName, assignPropertyWithResultSpec, callback_arguments, candidates, fn, highest_index, i, index, property_name, _j, _ref1;

        assignPropertyWithName = null;
        assignPropertyWithResultSpec = null;
        for (property_name in callback_spec) {
          match = /property_(.+)/.exec(property_name);
          if (match != null) {
            assignPropertyWithName = match[1];
            assignPropertyWithResultSpec = callback_spec[property_name];
          }
        }
        if (assignPropertyWithName) {
          host[assignPropertyWithName] = process_result_spec(assignPropertyWithResultSpec);
        }
        if (callback_spec.of) {
          if (typeof callback_spec.of !== 'object') {
            throw new Error('run_callback.of property was set to "' + callback_spec.of + '" - must be an object.');
          }
          if (callback_spec.of["arguments"] && !Array.isArray(callback_spec.of["arguments"])) {
            callback_spec.of["arguments"] = [callback_spec.of["arguments"]];
          }
          candidates = host.__callbacks.filter(function(c) {
            return c.function_name === callback_spec.of.function_name && ((callback_spec.of["arguments"] == null) || argument_arrays_equal(callback_spec.of["arguments"], c["arguments"]));
          });
          if (candidates.length === 0) {
            throw new Error('Tried to run callback provided to ' + callback_spec.of.function_name + ' along ' + 'with arguments [ ' + callback_spec.of["arguments"].join(', ') + ' ], ' + 'but didn\'t find any. Did you misspell ' + 'function_name or arguments, or perhaps the callback was never passed to ' + callback_spec.of.function_name + '?');
          }
          if (candidates.length > 1 && (callback_spec.of["arguments"] == null)) {
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
            if (callback_arguments[i] == null) {
              callback_arguments[i] = null;
            }
          }
          if (callback_arguments.length > 0) {
            callback_arguments;
          } else {
            null;
          }
        }
        return run_delayed(host, fn, callback_arguments, (_ref1 = callback_spec.delay) != null ? _ref1 : callback_spec.delay = 50);
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
        if (s == null) {
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
        if (argument_arrays_equal(call, args)) {
          return true;
        }
      }
      return false;
    };
    return host[function_name] = handler;
  };

  handle_function_call = function(host, handler, function_name) {};

  filter_on_function = function(expectations, function_name) {
    var e, _i, _len, _results;

    _results = [];
    for (_i = 0, _len = expectations.length; _i < _len; _i++) {
      e = expectations[_i];
      if (e.function_name === function_name) {
        _results.push(e);
      }
    }
    return _results;
  };

  filter_on_args = function(expectations, args_obj) {
    var actual_args_cleaned, matches_args_obj, result;

    result = function() {
      var e, _i, _len, _results;

      _results = [];
      for (_i = 0, _len = expectations.length; _i < _len; _i++) {
        e = expectations[_i];
        if (matches_args_obj(e)) {
          _results.push(e);
        }
      }
      return _results;
    };
    matches_args_obj = function(exp) {
      if (exp.check) {
        return exp.check.apply(null, actual_args_cleaned);
      } else if (exp["arguments"] != null) {
        if (!Array.isArray(exp["arguments"])) {
          throw new Error("arguments must be of type Array.");
        }
        return argument_arrays_equal(exp["arguments"], actual_args_cleaned);
      } else {
        return true;
      }
    };
    actual_args_cleaned = remove_functions(args_obj).filter(function(arg) {
      return !isUndefined(arg);
    });
    return result();
  };

  run_delayed = function(thisObj, fn, args, delay) {
    return setTimeout((function() {
      return fn.apply(thisObj, args);
    }), delay);
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

  argument_arrays_equal = function(a, b) {
    var i, item, _i, _len;

    if ((a != null) !== (b != null) || a.length !== b.length) {
      return false;
    }
    for (i = _i = 0, _len = a.length; _i < _len; i = ++_i) {
      item = a[i];
      if (item !== ANYTHING && !deepEquals(item, b[i])) {
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

    if (arguments_obj == null) {
      return [];
    }
    _results = [];
    for (_i = 0, _len = arguments_obj.length; _i < _len; _i++) {
      arg = arguments_obj[_i];
      _results.push(arg);
    }
    return _results;
  };

  module.exports = {
    ANYTHING: ANYTHING,
    lie: lieFunc,
    macros: macros
  };

}).call(this);
