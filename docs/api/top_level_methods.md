# Top Level Methods

The following methods are exposed on the object returned when nectarine is required / imported.

---

#### `connect({component, mapProps})`

* `component` - a `React.Component` to be wrapped
* `mapProps(store, ownProps)` - a function used to expose the necessary parts of the store to the component

Returns a wrapped `React.Component`.

---

#### `createSlice({schema, actions})`

* `schema` - an object or a function that accepts two placeholder arguments and returns an object or a placeholder.
* `actions` - an object to define function to make available on the slice.

Returns a slice that should to be passed to `createStore` or another call to `createSlice`. Not useable on its own.

See [here](../creating_a_slice.md) for a more detailed explanation about creating slices.

---

#### `createStore(sliceMapping [, options])`

* `sliceMapping` - an object where the values are slices
* `options` - object with the following keys
  * `dependencies` - an object of dependencies to inject into actions. See [here](../creating_a_slice.md#actions)

Returns a store. Can be passed as a prop to `Provider` or used directly as needed.

---

#### `Provider`

A `React.Component` which accepts a `store` as prop.
