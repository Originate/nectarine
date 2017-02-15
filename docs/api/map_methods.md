# Map Methods

Map placeholders will create objects which have the following methods:

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
