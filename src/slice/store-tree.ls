require! {
  './helpers': {build-child-node}
  './store-node': StoreNode
}


class StoreTree extends StoreNode

  ->
    super ...
    for own key, value of @_schema
      @[key] = build-child-node this, value, key


  $get-error: ->
    for own key of @_schema
      err = @[key].$get-error!
      return err if err?
    null


  $from-promise: (promise) ->
    @$set-loading!
    promise
      .then (data) ~>
        unless data?.constructor is Object
          return Promise.reject Error "#{@$get-path-string!} $from-promise: called on a tree but promise resolved to a #{typeof! data}"
        @$set data
      .catch (err) ~>
        @$set-error err
        Promise.reject err


  $is-loading: ->
    for own key of @_schema when @[key].$is-loading!
      return yes
    no


  $reset: ->
    @_for-each-subnode (subnode) -> subnode.$reset!


  $set: (data) !->
    switch typeof! data
    | \Object   => @_for-each-subnode (subnode, key) -> subnode.$set data[key] if data[key] isnt undefined
    | \Null     => @_for-each-subnode (subnode) -> subnode.$set null
    | otherwise => throw Error 'calling $set on a tree must be called with an object or null'


  $set-loading: (loading = yes) !->
    @_for-each-subnode (subnode) -> subnode.$set-loading loading


  $set-error: (err) !~>
    @_for-each-subnode (subnode) -> subnode.$set-error err


  $get: ->
    obj = {}
    @_for-each-subnode (subnode, key) -> obj[key] = subnode.$get!
    obj


  _for-each-subnode: (fn) !->
    for own key of @_schema
      fn @[key], key


module.exports = StoreTree
