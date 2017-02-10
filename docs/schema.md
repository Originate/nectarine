# Schema

When defining a schema with `create-slice`, `schema` should be an object or a function that returns an object.
When schema is a function, it passed two arguments. A leaf placeholder and a map placeholder.

# Leaf Placeholder

The first argument to schema is a leaf placeholder. This is used anywhere you would like to store data.
A leaf placeholder by itself stands for `type: any`.

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

Placeholders can also be called as functions and passed in any of the following options:

* `required` - boolean for whether or not this value must be populated (non-null). If set to true, an `initialValue` must be given.
* `initialValue` - self explanatory. The type will be inferred from it.
* `type` - a string of a primitive type ('array', 'boolean', 'function', 'number', 'object', 'string'), a constructor, or 'any'
* `validate` - function for extra validation. Called with a value and should return a boolean

```js
schema = _ => (
  {
    currentUser: {
      name: _({type: 'string'}),
      email: _({type: 'string', required: true})
    }
  }
)
```

# Map Placeholder

The second argument is a map placeholder function. Maps are used for nested objects that will be saved at dynamic keys.
`map` must be passed a child schema.

```js
schema = (_, map) => (
  {
    users: map({
      name: _({type: 'string'}),
      email: _({type: 'string', required: true})
    })
  }
)
```

# Nested slices

A slice can be used anywhere a placeholder can.

```js
const userSearchSlice = createSlice({
  schema: (_, map) => (
    query: _,
    results: map({
      name: _(type: 'string'),
      email: _(type: 'string', required: true)
    })
  )
})

const userManagementSlice = createSlice({
  schema: (_, map) => (
    currentView: _,
    userSearch: userSearchSlice
    // ...
  )
})
```
