Beautiful Lies
==============

Test doubles for asynchronous javascript that are
easy to *read*, *write* and *debug*.


## Expectation
```javascript
{
  function_called: 'collection',
  with_arguments: [ 'members' ],
  returns: /* RETURN BLOCK GOES HERE */
  yields_in_order: /* ARRAY OF YIELDS GOES HERE */
  yields_as_flow: /* ARRAY OF YIELDS GOES HERE*/
}
```

## Return block
```javascript
{
  value: { someProperty: 5 }
  on_value: /* ARRAY OF EXPECTATIONS GOES HERE */
},
```

## Yield
```javascript
{
  argument_1st: /* RETURN BLOCK GOES HERE */
  argument_2nd: /* RETURN BLOCK GOES HERE*/,
  on_3rd_argument: /* ARRAY OF EXPECTATIONS GOES HERE */
}
```









