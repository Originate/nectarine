require! {
  './store-tree/schema-placeholder': SchemaPlaceholder
}


class SliceData

  ({@actions, @schema}) ->
    if typeof! @schema is \Function
      @schema = @schema SchemaPlaceholder.create-placeholder, SchemaPlaceholder.create-map


module.exports = SliceData
