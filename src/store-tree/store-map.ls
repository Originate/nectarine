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


  $from-promise: ->
    throw Error @_buildErrorMessage '$fromPromise()', '$key(k).$fromPromise(v)'


  $get-error: ->
    throw Error @_buildErrorMessage '$getError()', "$getAll('error')"


  $get: ->
    throw Error @_buildErrorMessage '$get()', '$getAll()'


  $get-all: (type = 'data') ->
    obj = {}
    for own key of @_mapping
      if @_mapping[key].$is-loading!
        if type is 'loading' then obj[key] = true
      else if error = @_mapping[key].$get-error!
        if type is 'error' then obj[key] = error
      else
        if type is 'data' then obj[key] = @_mapping[key].$get!
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


  $set: ->
    throw Error @_buildErrorMessage '$set()', "$key(k).$set(v)"


  $set-error: ->
    throw Error @_buildErrorMessage '$setError()', "$key(k).$setError(e)"


  $set-loading: ->
    throw Error @_buildErrorMessage '$setLoading()', "$key(k).$setLoading()"


  _buildErrorMessage: (disallowed, suggestion) ->
    "Error at `#{@$get-path-string!}`: #{disallowed} can not be used on a map. Use #{suggestion}"


module.exports = StoreMap
