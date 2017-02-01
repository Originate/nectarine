require! {
  './schema-placeholder': SchemaPlaceholder
  './store-leaf': StoreLeaf
  './store-node': StoreNode
  './helpers': {build-child-node}
}


class StoreMap extends StoreNode

  ->
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
    @_mapping[key] or= build-child-node this, @_schema.child-schema, key


module.exports = StoreMap
