class SliceData

  ({@actions, schema}) ->
    @schema = switch typeof! schema
    | \Function => schema SchemaPlaceholder.create-placeholder, SchemaPlaceholder.create-map
    | \Object   => schema
    | otherwise => throw new Error '"schema" must be a function or object'


module.exports = SliceData
