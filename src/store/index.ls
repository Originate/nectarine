require! {
  './schema-placeholder': SchemaPlaceholder
  './store-tree': StoreTree
}


exports.create-store = (get-schema) ->
  schema = get-schema SchemaPlaceholder.create-placeholder
  new StoreTree schema, []
