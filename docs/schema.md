# Schema

When defining a schema with `create-slice`, schema should be an object or a function that returns an object. The first argument to schema is a generic placeholder object / function.

Placeholders stand for `type: any`. In the following example we are defining a schema where `currentUser` has two properties with that can have any type.

```js
schema = _ => (
  {
    currentUser: {
      name: _,
      email: _
    }
  }
)
```

Placeholders can also be called as functions and passed in a number of options. The options are:

* `allowNull` - boolean for whether or not null is valid. If set to false an `initialValue` must be given.
* `initialValue` - self explanatory. The type will be inferred from this if not provided.
* `type` - set the type with a string of a primative type ('array', 'boolean', 'function', 'number', 'object', 'string'), a constructor, or 'any'
* `validate` - function for type validation. Return a boolean

```js
schema = _ => (
  {
    currentUser: {
      name: _(type: 'string'),
      email: _(type: 'string', allowNull: true)
    }
  }
)
```

The second argument is a map placeholder function. Maps are used for dynamic sets of data
