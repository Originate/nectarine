require! {
  './schema-placeholder': SchemaPlaceholder
  './store-leaf': StoreLeaf
  './store-node': StoreNode
  './helpers': {build-store-node}
  'prelude-ls': {Obj: {map}}
}


class StoreMap extends StoreNode

  ({child-schema: @_child-schema}) ->
    super ...
    @_mapping = {}


  $debug: ->
    @_mapping |> map (.$debug!)


  $delete: (key) ->
    delete @_mapping[key]


  $from-promise: ->
    throw Error @_build-error-message '$fromPromise()', '$key(k).$fromPromise(v)'


  $get-error: ->
    throw Error @_build-error-message '$getError()', "$getAll('error')"


  $get: ->
    throw Error @_build-error-message '$get()', '$getAll()'


  $get-all: ->
    obj = {}
    for own key, value of @_mapping
      try obj[key] = value.$get!
    obj


  $is-loading: ->
    throw Error @_build-error-message '$isLoading()', "$getAll('loading')"


  $key: (key) ->
    @_mapping[key] or= @_build-child key


  $keys: ->
    Object.keys @_mapping


  $set: ->
    throw Error @_build-error-message '$set()', "$key(k).$set(v)"


  $set-error: ->
    throw Error @_build-error-message '$setError()', "$key(k).$setError(e)"


  $set-loading: ->
    throw Error @_build-error-message '$setLoading()', "$key(k).$setLoading()"


  _build-child: (key) ->
    build-store-node path: @$get-path!.concat(key), schema: @_child-schema
      ..$on-update @$emit-update


  _build-error-message: (disallowed, suggestion) ->
    "Error at `#{@$get-path-string!}`: #{disallowed} can not be used on a map. Use #{suggestion}"


module.exports = StoreMap
