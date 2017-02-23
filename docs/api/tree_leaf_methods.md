# Tree / Leaf Methods

Nested objects (referred to as trees) and leaf placeholders create objects with the following methods:

---

#### `$get()`

Returns the value for this node.
This function throws an error if the node is loading or has an error.

---

#### `$getError()`

Returns the error for this node. Returns null if it does not have an error.
If this node is a tree, returns any child's error or null.

---

#### `$getPath()`

Returns an array of strings which is the path from the root of the store to this node.

---

#### `$hasData()`

Returns whether or not the node's value is non-null.
If this node is a tree, returns whether or not any child is non-null.
Returns false if the node is loading or has an error.

---

#### `$isLoading()`

Returns a boolean for whether or not this node is loading.
If this node is a tree, returns true if any child is loading.

---

#### `$onUpdate(callback)`

Register a callback to receive updates any times the node changes.
If the node is a tree, the callback will receive updates for each child.
The callback will be called with the parameters `{path, updates}`.
`path` is an the result of `$getPath()` for the node where the update occurred.
`updates` is an array of the form `{path, oldValues, newValues}` and there will be for every leaf that changed.
`oldValues` and `newValues` have the form `{data, error, loading}` and `path` is the the result of `$getPath()` for the leaf.

---

#### `$fromPromise(promise)`

Immediately sets the node to loading.
The node will then be set to the resolved value or have its error set to the rejection reason.

---

#### `$set(value)`

Sets the value for this node.
If this node is a tree and `value` is an object, sets only the children whose keys are present in `value`.
If this node is a tree and `value` is `null`, sets all children to `null`

---

#### `$setError(error)`

Sets the error for this node.
If this node is a tree, it sets the error for all children.

---

#### `$setLoading(isLoading)`

Sets whether or not this node is loading. If called with no arguments, it sets loading to true.
If this node is a tree, it sets loading for all children.
