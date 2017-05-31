# Map Methods

Map placeholders will create objects which are very similar to [Trees / Leafs](./tree_leaf_methods.md).
The `$fromPromise`, `$set`, `$setError`, and `$setLoading` methods throw errors
as the map should not be set at once but instead all have its individual keys set.
The following methods are map specific:

---

#### `$delete(key)`

Removes the node for that particular key. `$get()` and `$keys()` will no longer include the node.

---

#### `$key(key)`

Returns the node for that particular key.
This initializes a new node if one does not exist.

---

#### `$keys()`

Returns the keys of all initialized nodes.
