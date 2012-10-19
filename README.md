Beautiful Lies
==============

Test doubles for asynchronous javascript that are
easy to *read*, *write* and *debug*.


Expectation
===============
```javascript
{
  function_called: 'collection',
  with_arguments: [ 'members' ],
  returns: /* RETURN BLOCK */
  yields_in_order: /* ARRAY OF YIELDS */
  yields_as_flow: /* ARRAY OF YIELDS */
}
´´´

Return block
===============
```javascript
{
  value: { someProperty: 5 }
  on_value: /* ARRAY OF EXPECTATIONS */
},
``



Yield
=======
```javascript
{
  argument_1st: /* RETURN BLOCK */
  argument_2nd: /* RETURN BLOCK */,
  on_3rd_argument: /* ARRAY_OF_EXPECTATIONS */
}
´´´









