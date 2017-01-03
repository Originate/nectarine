class StoreNode

  (@_schema, @_path) ->
    @_update-callbacks = []


  $on-update: (callback) ->
    @_update-callbacks.push callback


  $emit-update: (...args) ~>
    for callback in @_update-callbacks
      callback.apply {}, args


module.exports = StoreNode
