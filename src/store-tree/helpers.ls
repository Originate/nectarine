require! {
  './schema-placeholder': SchemaPlaceholder
  '../slice-data': SliceData
}


build-store-tree = (options) ->
  children = {}
  for own key, childSchema of options.schema
    childOptions =
      get-action-context: options.get-action-context
      path: options.path.concat(key)
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
  | SchemaPlaceholder.is-placeholder(schema) => new (require './store-leaf') options
  | SchemaPlaceholder.is-map(schema)         => new (require './store-map') {child-schema: schema.child-schema, ...options}
  | typeOf! schema is 'Object'               => build-store-tree options
  | otherwise                                => throw new Error "Invalid schema: `#{path.join('.')}` should be a placeholder or an object"


module.exports = {build-store-node}
