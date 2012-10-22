Beautiful Lies
==============

Test doubles for asynchronous javascript that are easy on the eyes.

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
that has three basic types of building blocks - expectations, results and yields:

### Expectation object
```javascript
{
  function_name: 'collection',
  arguments: [ 'members' ],
  returns: /* RESULT OBJECT GOES HERE */
  yields_in_order: /* ARRAY OF YIELD OBJECTS GOES HERE */
  yields_as_flow: /* ARRAY OF YIELD OBJECTS GOES HERE*/
}
```

### Result object
```javascript
{
  value: { someProperty: 5 }
  on_value: /* ARRAY OF EXPECTATIONS GOES HERE */
},
```

### Yield object
```javascript
{
  argument_1: /* RESULT OBJECT GOES HERE */
  argument_2: /* RESULT OBJECT GOES HERE*/,
  delay: 1000
}
```


## Plugins
Expectations, results and yields are buildings blocks that can be used to construct plugins (on_promise_done is a plugin, for instance). Check out the built in plugins here, for inspiration:
https://github.com/mpj/beautiful_lies/blob/master/plugins.coffee








