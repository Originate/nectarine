require! {
  './schema-placeholder': SchemaPlaceholder
  './store-leaf': StoreLeaf
  './store-node': StoreNode
  './helpers': {build-store-node}
  'prelude-ls': {each, Obj, obj-to-pairs}
}


class StoreMap extends StoreNode

  ({child-schema: @_child-schema}) ->
    super ...
    @_mapping = {}


  $debug: ->
    @_mapping |> Obj.map (.$debug!)


  $from-promise: ->
    throw Error @_buildErrorMessage '$fromPromise()', '$key(k).$fromPromise(v)'


  $get-error: ->
    throw Error @_buildErrorMessage '$getError()', "$getAll('error')"


  $get: ->
    throw Error @_buildErrorMessage '$get()', '$getAll()'


  $get-all: ->
    obj = {}
    for own key of @_mapping
      try obj[key] = @_mapping[key].$get!
    obj


  $is-loading: ->
    throw Error @_buildErrorMessage '$isLoading()', "$getAll('loading')"


  $key: (key) ->
    unless @_mapping[key]
      @_mapping[key] = build-store-node do
        path: @$get-path!.concat(key)
        schema: @_child-schema
      @_mapping[key].$on-update @$emit-update
    @_mapping[key]


  $keys: -> Object.keys @_mapping


  $set: ->
    throw Error @_buildErrorMessage '$set()', "$key(k).$set(v)"


  $set-error: ->
    throw Error @_buildErrorMessage '$setError()', "$key(k).$setError(e)"


  $set-loading: ->
    throw Error @_buildErrorMessage '$setLoading()', "$key(k).$setLoading()"


  _buildErrorMessage: (disallowed, suggestion) ->
    "Error at `#{@$get-path-string!}`: #{disallowed} can not be used on a map. Use #{suggestion}"


module.exports = StoreMap
