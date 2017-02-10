# Map Methods

Map placeholders will create objects which have the following methods:

#### $getAll(type = 'data')

When type is `'data'`, returns a mapping from `key` to `$key(key).$get()` for all keys with data
When type is `'error'`, returns a mapping from `key` to `$key(key).$getError()` for all keys with errors
When type is `'loading'`, returns a mapping from `key` to `true` for all keys that are loading

#### $key(key)

Returns the node for that particular key.
This initializes a new node if one does not exist.
