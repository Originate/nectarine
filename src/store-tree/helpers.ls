require! {
  './schema-placeholder': SchemaPlaceholder
  '../slice-data': SliceData
}


build-store-tree = (options) ->
  children = {}
  for own key, childSchema of options.schema
    childOptions = {path: path.concat(key)}
    if childSchema instanceof SliceData
      childOptions.actions = childSchema.actions
      childOptions.schema = childSchema.schema
    else
      childOptions.schema = childSchema
    children[key] = build-store-node childOptions
  new (require './') {children, ...options}


build-store-node = (options) ->
  {path, schema} = options
  switch
  | SchemaPlaceholder.is-placeholder(schema) => new (require './store-leaf') {schema, path}
  | SchemaPlaceholder.is-map(schema)         => new (require './store-map') {child-schema: schema.child-schema, path}
  | otherwise                                => build-store-tree options


module.exports = {build-store-node}
