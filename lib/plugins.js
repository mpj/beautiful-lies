(function() {
  var plugins;

  plugins = {
    callback_result: function(obj) {
      return {
        run_callback: [
          {
            argument_2: obj
          }
        ]
      };
    },
    on_callback_result: function(obj) {
      return {
        run_callback: [
          {
            argument_2: {
              on_value: obj
            }
          }
        ]
      };
    },
    callback_error_value: function(obj) {
      return {
        run_callback: [
          {
            argument_1: {
              value: obj
            }
          }
        ]
      };
    },
    promise_done: function(result_spec) {
      return {
        returns: {
          on_value: [
            {
              function_name: 'done',
              run_callback: [
                {
                  argument_1: result_spec
                }
              ]
            }, {
              function_name: 'fail'
            }
          ]
        }
      };
    },
    on_promise_done: function(obj) {
      return plugins.promise_done({
        on_value: obj
      });
    },
    promise_done_value: function(obj) {
      return plugins.promise_done({
        value: obj
      });
    },
    promise_fail: function(obj) {
      return {
        returns: {
          on_value: [
            {
              function_name: 'fail',
              run_callback: [
                {
                  argument_1: obj
                }
              ]
            }, {
              function_name: 'done'
            }
          ]
        }
      };
    },
    promise_fail_value: function(obj) {
      return plugins.promise_fail({
        value: obj
      });
    }
  };

  module.exports = plugins;

}).call(this);
