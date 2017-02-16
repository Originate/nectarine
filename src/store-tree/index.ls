require! {
  './store-node': StoreNode
  'prelude-ls': {any, each, find, id, intersection, map, Obj, obj-to-pairs, values}
}


class StoreTree extends StoreNode

  ({actions, children: @_children}) ->
    super ...
    for own key, value of @_children
      @[key] = value
      value.$on-update @$emit-update

    clashes = intersection Object.keys(@_children), Object.keys(actions or {})
    if clashes.length > 0
      throw new Error """
        `#{@$get-path-string!}`: schema and action keys clash. The following keys are ambiguous. Update them to be unique
          #{clashes.join('\n  ')}
        """


  $get-error: ->
    @_children |> values |> find (.$get-error!) |> -> it?.$get-error! or null


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
    @_children |> values |> any (.$is-loading!)


  $reset: !-> @$batch-emit-updates ~>
    @_children |> Obj.each (.$reset!)


  $set: (data) !-> @$batch-emit-updates ~>
    switch typeof! data
    | \Object   => @_children |> obj-to-pairs |> each ([key, subnode]) -> subnode.$set data[key] if data[key] isnt undefined
    | \Null     => @_children |> Obj.each (.$set null)
    | otherwise => throw Error 'calling $set on a tree must be called with an object or null'


  $set-loading: (loading = yes) !-> @$batch-emit-updates ~>
    @_children |> Obj.each (.$set-loading loading)


  $set-error: (err) !~> @$batch-emit-updates ~>
    @_children |> Obj.each (.$set-error err)


  $get: ->
    @_children |> Obj.map (.$get!)


  $debug: ->
    @_children |> Obj.map (.$debug!)


module.exports = StoreTree
