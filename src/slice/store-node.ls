require! {
  'lodash.pull': pull
}


class StoreNode

  (@_schema) ->
    @_update-callbacks = []


  $off-update: (callback) ->
    pull @_update-callbacks, callback


  $on-update: (callback) ->
    @_update-callbacks.push callback


  $emit-update: (...args) ~>
    for callback in @_update-callbacks
      callback.apply {}, args


  $get-path: ->
    | @_parent? => @_parent.$get-path!.concat @_key
    | otherwise => []


  $get-path-string: ->
    @$get-path!.join '.'


  $get-root: ->
    @_parent?.$get-root! or this


  $set-parent: (@_parent, @_key) ->


  $inject: (@_dependencies) ->


module.exports = StoreNode
