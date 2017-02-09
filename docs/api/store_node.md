# Store Node Methods

## Getters

### $get()

Returns the value for this node.
This function throws an error if the node is loading or has an error.

### $getError()

Returns the error for this node. Returns null if it does not have an error.
If this node is a tree, returns any child's error or null.

### $isLoading()

Returns a boolean for whether or not this node is loading.
If this node is a tree, returns true if any child is loading.

### $onUpdate(callback)

Register a callback to receive updates any times the node changes.
If the node is a tree, the callback will receive updates for each child.
The callback will be executed with the new value, the old value, and the path that updated.
The new value and old value have the form `{data, error, loading}`.
The path is an array from the root to where the change occurred.

## Setters

### $fromPromise(promise)

Immediately sets the node to loading.
The node will then be set to resolved value or have its error set to the rejection reason.

### $set(value)

Sets the value for this node.
If this node is a tree and `value` is an object, sets only the children whose keys are present in `value`.
If this node is a tree and `value` is `null`, sets all children to `null`

### $setError(error)

Sets the error for this node.
If this node is a tree, it sets the error for all children.

### $setLoading(isLoading)

Sets whether or not this node is loading. If called with no arguments, it sets loading to true.
If this node is a tree, it sets loading for all children.
