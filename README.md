Beautiful Lies
==============

Test doubles for asynchronous javascript that are
easy to *read*, *write* and *debug*.

## Syntax

### Basic example:
```javascript
var db = create_liar([{
  function_name: 'connect',
  yields_in_order: {
    argument_2: {
      on_value: [{
        function_name: 'query',
        yields_in_order: [{
          argument_1: {
            type: 'TimeoutError',
            message: 'The query timed out.'
          },
          delay: 1000
        }]
      }]
    }
  }
}])

// The code below will output
// "The query timed out" after 1000ms.
db.connect(function(err, connection) {
  connection.query(function(err, result) {
    console.log(err.message);
  })
})

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
}
```









