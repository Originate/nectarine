require! {
  './schema-placeholder': SchemaPlaceholder
}


build-store-tree = ({actions, schema, path}) ->
  children = {}
  for own key, childSchema of schema
    childOptions = {path: path.concat(key), store}
    if childSchema instanceof SliceData
      childOptions.actions = childSchema.actions
      childOptions.schema = childSchema.schema
    else
      childOptions.schema = childSchema
    children[key] = build-store-node childOptions
  new (require './store-node') {actions, children, path}


build-store-node = ({actions, schema, path}) ->
  switch
  | SchemaPlaceholder.is-placeholder(schema) => new (require './store-leaf') {schema, path}
  | SchemaPlaceholder.is-map(schema)         => new (require './store-map') {child-schema: schema.child-schema, path}
  | otherwise                                => build-store-tree {actions, schema, path}


module.exports = {build-child-node}
