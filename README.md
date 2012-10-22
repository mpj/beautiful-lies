Beautiful Lies
==============

Test doubles for asynchronous javascript that are
easy to *read*, *write* and *debug*.

#### Let's say you want to mock this...
```javascript
db.connect(function(err, connection) {
  connection.query(function(err, result) {
    console.log(err.message);
  })
})
```

```javascript
var db = create_liar([{
  function_name: 'connect',
  callback_result: {
    on_value: [{
      function_name: 'query',
      callback_error: {
        value: {
          type: 'TimeoutError',
          message: 'The query timed out.'
        }
      }]
    }]
  }
}])
```

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









