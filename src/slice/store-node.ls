require! {
  'lodash.pull': pull
}


class StoreNode

  (@_schema, @_parent, @_key) ->
    @_update-callbacks = []


  $off-update: (callback) ->
    pull @_update-callbacks, callback


  $on-update: (callback) ->
    @_update-callbacks.push callback


  $emit-update: (...args) ~>
    for callback in @_update-callbacks
      callback.apply {}, args


  $get-path-string: ->
    path = [@_key]
    parent-path = @_parent?.$get-path-string?!
    path.unshift parent-path if parent-path
    path.join '.'


  $get-root: ->
    @_parent?.$get-root! or this


  $set-path: (@_parent, @_key) ->


  $inject: (@_dependencies) ->


module.exports = StoreNode
