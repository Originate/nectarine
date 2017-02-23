# Map Methods

Map placeholders will create objects which have the following methods:

---

#### `$delete(key)`

Remove a node. `$getAll()` and `$keys()` will no longer include the node.

---

#### `$getAll()`

Returns a mapping from `key` to `$key(key).$get()` for all keys with data.

---

#### `$key(key)`

Returns the node for that particular key.
This initializes a new node if one does not exist.

---

#### `$keys()`

Returns the keys of all initialized nodes.
