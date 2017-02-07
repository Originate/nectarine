require! {
  './helpers': {build-child-node}
  './store-node': StoreNode
}


class StoreTree extends StoreNode

  ({actions, children: @_children, get-action-context: @_get-action-context, path}) ->
    super ...
    for own key, value of @_children
      @[key] = value
      value.$on-update @$emit-update

    if actions?
      for own actionName, action-fn of actions
        @_bind-action action-name, action-fn


  $get-error: ->
    for own key of @_children
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
    for own key of @_children when @[key].$is-loading!
      return yes
    no


  $reset: -> @$batch-emit-updates ~>
    @_for-each-subnode (subnode) -> subnode.$reset!


  $set: (data) !-> @$batch-emit-updates ~>
    switch typeof! data
    | \Object   => @_for-each-subnode (subnode, key) -> subnode.$set data[key] if data[key] isnt undefined
    | \Null     => @_for-each-subnode (subnode) -> subnode.$set null
    | otherwise => throw Error 'calling $set on a tree must be called with an object or null'


  $set-loading: (loading = yes) !-> @$batch-emit-updates ~>
    @_for-each-subnode (subnode) -> subnode.$set-loading loading


  $set-error: (err) !~> @$batch-emit-updates ~>
    @_for-each-subnode (subnode) -> subnode.$set-error err


  $get: ->
    obj = {}
    @_for-each-subnode (subnode, key) -> obj[key] = subnode.$get!
    obj


  _bind-action: (action-name, action-fn) ->
    if @[action-name]
      throw new Error "Failed to create slice: Action \"#{action-name}\" would override schema"

    @[action-name] = (...args) ~>
      context = {slice: this, ...@_get-action-context!}
      action-fn.apply context, args


  _for-each-subnode: (fn) !->
    for own key of @_children
      fn @[key], key


module.exports = StoreTree
