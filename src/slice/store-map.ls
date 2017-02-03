require! {
  './schema-placeholder': SchemaPlaceholder
  './store-leaf': StoreLeaf
  './store-node': StoreNode
  './helpers': {build-store-node}
}


class StoreMap extends StoreNode

  ({child-schema: @_child-schema}) ->
    super ...
    @_mapping = {}


  $get-error: ->
    for own key of @_mapping
      err = @_mapping[key].$get-error!
      return err if err?
    null


  $get: ->
    obj = {}
    for own key of @_mapping
      obj[key] = @_mapping[key].$get!
    obj


  $is-loading: ->
    for own key of @_mapping when @_mapping[key].$is-loading!
      return yes
    no


  $key: (key) ->
    unless @_mapping[key]
      @_mapping[key] = build-store-node do
        path: @$get-path.concat(key)
        schema: @_child-schema
      @_mapping[key].$on-update @$emit-update
    @_mapping[key]


  $set-store: (@_store) ->
    for own key, value of @_mapping
      value.$set-store @_store


module.exports = StoreMap
