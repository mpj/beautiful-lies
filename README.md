Beautiful Lies
==============
[![Build status][1]][2]
[![Dependency status][3]][4]

[1]: https://api.travis-ci.org/mpj/beautiful-lies.png
[2]: https://travis-ci.org/mpj/beautiful-lies
[3]: https://david-dm.org/mpj/beautiful-lies.png
[4]: https://david-dm.org/mpj/beautiful-lies#info=devDependencies&view=table

Mocks for asynchronous JavaScript that are easy on the eyes.  Yay! Hooray! Fnuff.

#### Create a test double ...
```javascript
var beautiful = require('beautiful-lies')
    beautiful.lie()

var db = {}
db.lie({
  function_name: 'connect',
  on_promise_done: {
    function_name: 'query',
    promise_fail_value: {
      message: 'The query timed out.'
    }
  }
})
```
#### And call it ...
```javascript
db.connect().done(function() {
  db.query().fail(function(error) {
    console.log(error.message) // <-- Will output 'The query timed out.'
  })
})
```

## Syntax

Liars are generated using a simple, hierarchial JSON-based DSL,
that has three basic types of building specifications: expectations, results and callbacks.

### Expectation specification
```javascript
{
  function_name: 'collection',
  arguments: [ 'members' ],
  check: function() { return true },
  returns: /* RESULT SPEC GOES HERE */
  run_function: function() {
    // anything you want here.
  }
  run_callback: /* ARRAY OF CALLBACK SPECS GOES HERE */
  run_callback_flow: /* ARRAY OF CALLBACK SPECS GOES HERE*/
}
```

### Result specification
```javascript
{
  self: false
  value: { someProperty: 5 }
  on_value: /* ARRAY OF EXPECTATION SPECS GOES HERE */
},
```

### Callback specification
```javascript
{
  property_xxxx: /* RESULT SPEC GOES HERE */,
  argument_1: /* RESULT SPEC GOES HERE */,
  argument_2: /* RESULT SPEC GOES HERE*/,
  of: {
    function_name: 'addEventListener'
    arguments: [ 'click' ]
  },
  delay: 1000
}
```


## Macros
Expectations, results and callback object are buildings blocks that can be used to construct macros (on_promise_done is a plugin, for instance). Check out the built-in macros here, for inspiration:
https://github.com/mpj/beautiful-lies/blob/master/src/macros.coffee








