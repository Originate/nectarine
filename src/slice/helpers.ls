require! {
  './schema-placeholder': SchemaPlaceholder
}


# just in time requires to avoid circular requires
build-child-node = (parent, value, key) ->
  node = switch
  | value instanceof require('./store-node')     => value
  | SchemaPlaceholder.is-leaf-placeholder(value) => new (require './store-leaf') value
  | SchemaPlaceholder.is-map-placeholder(value)  => new (require './store-map') value
  | otherwise                                    => new (require './store-tree') value

  node
    ..$set-parent parent, key
    ..$on-update parent.$emit-update


module.exports = {build-child-node}
