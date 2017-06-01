require! {
  './schema-placeholder': SchemaPlaceholder
  './store-leaf': StoreLeaf
  './': StoreTree
  './helpers': {build-store-node}
  'prelude-ls': {Obj: {map}}
  '../utils': {merge-objects}
}


class StoreMap extends StoreTree

  (options) ->
    {child-schema: @_child-schema} = options
    super merge-objects(options, children: {})


  $delete: (key) ->
    delete @_children[key]


  $from-promise: ->
    throw Error @_build-error-message '$fromPromise()', '$key(k).$fromPromise(v)'


  $key: (key) ->
    @_children[key] or= @_build-child key


  $keys: ->
    Object.keys @_children


  $set: ->
    throw Error @_build-error-message '$set()', "$key(k).$set(v)"


  $set-error: ->
    throw Error @_build-error-message '$setError()', "$key(k).$setError(e)"


  $set-loading: ->
    throw Error @_build-error-message '$setLoading()', "$key(k).$setLoading()"


  _build-child: (key) ->
    build-store-node path: @$get-path!.concat(key), schema: @_child-schema
      ..$on-update @$emit-update.bind(@)


  _build-error-message: (disallowed, suggestion) ->
    "Error at `#{@$get-path-string!}`: #{disallowed} can not be used on a map. Use #{suggestion}"


module.exports = StoreMap
