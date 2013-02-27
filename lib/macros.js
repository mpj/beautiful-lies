(function() {
  var macros;

  macros = {
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
              ],
              returns: {
                self: true
              }
            }, {
              function_name: 'fail',
              returns: {
                self: true
              }
            }
          ]
        }
      };
    },
    on_promise_done: function(obj) {
      console.warn('on_promise_done is deprecated, use on_promise_done_value');
      return {
        promise_done: {
          on_value: obj
        }
      };
    },
    on_promise_done_value: function(obj) {
      return {
        promise_done: {
          on_value: obj
        }
      };
    },
    promise_done_value: function(obj) {
      return {
        promise_done: {
          value: obj
        }
      };
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
              ],
              returns: {
                self: true
              }
            }, {
              function_name: 'done',
              returns: {
                self: true
              }
            }
          ]
        }
      };
    },
    promise_fail_value: function(obj) {
      return {
        promise_fail: {
          value: obj
        }
      };
    }
  };

  module.exports = macros;

}).call(this);
