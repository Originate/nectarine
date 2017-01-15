require! {
  'lodash.pull': pull
}


class StoreNode

  (@_schema, @_path) ->
    @_update-callbacks = []


  $off-update: (callback) ->
    pull @_update-callbacks, callback


  $on-update: (callback) ->
    @_update-callbacks.push callback


  $emit-update: (...args) ~>
    for callback in @_update-callbacks
      callback.apply {}, args


  $get-path-string: ->
    @_path.join('.') or '[root]'


  $prepend-to-path: (key) ->
    @_path.unshift key


  $inject: (@_dependencies) ->


module.exports = StoreNode
