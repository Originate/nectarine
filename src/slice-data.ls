require! {
  './store-tree/schema-placeholder': SchemaPlaceholder
}

class SliceData

  ({@actions, @schema}) ->
    if typeof! @schema is \Function
      @schema = @schema SchemaPlaceholder.create-placeholder, SchemaPlaceholder.create-map

    if typeof! @schema is not \Object
      throw new Error '"schema" must be an object or a function that returns an object'


module.exports = SliceData
