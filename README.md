Beautiful Lies
==============
![Build status](https://api.travis-ci.org/mpj/beautiful-lies.png)

Mocks for asynchronous JavaScript that are easy on the eyes. Yay!

#### Create a test double ...
```javascript
var db = create_liar([{
  function_name: 'connect',
  on_promise_done: [{
    function_name: 'query',
    promise_fail_value: {
      message: 'The query timed out.'
    }
  }]
}])
```
#### And call it ...
```javascript
db.connect().done(function() {
  db.query().fail(function(error) {
    console.log(error.message); // <-- Will output 'The query timed out.'
  })
})
```

## Syntax

Liars are generated using a basic hierarchial JSON-based language,
that has three basic types of building blocks - expectations specs, result specs and callback specs:

### Expectation spec
```javascript
{
  function_name: 'collection',
  arguments: [ 'members' ],
  returns: /* RESULT SPEC GOES HERE */
  run_function: function() {
    // anything you want here.
  }
  run_callback: /* ARRAY OF CALLBACK SPECS GOES HERE */
  run_callback_flow: /* ARRAY OF CALLBACK SPECS GOES HERE*/
}
```

### Result spec
```javascript
{
  self: false
  value: { someProperty: 5 }
  on_value: /* ARRAY OF EXPECTATION SPECS GOES HERE */
},
```

### Callback spec
```javascript
{
  argument_1: /* RESULT SPEC GOES HERE */
  argument_2: /* RESULT SPEC GOES HERE*/,
  of:
    function_name: 'addEventListener'
    arguments: [ 'click' ]
  delay: 1000
}
```


## Plugins
Expectations, results and callback object are buildings blocks that can be used to construct plugins (on_promise_done is a plugin, for instance). Check out the built in plugins here, for inspiration:
https://github.com/mpj/beautiful-lies/blob/master/plugins.coffee








