require! {
  'lodash.pull': pull
}


batchId = 0


class StoreNode

  (@_schema) ->
    @_update-callbacks = []
    @_queued-updates = []


  $off-update: (callback) ->
    pull @_update-callbacks, callback


  $on-update: (callback) ->
    @_update-callbacks.push callback


  $emit-update: (...args) ~>
    if @_should-queue-updates
      @_queued-updates.push args
    else
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


  $get-or-else: (defaultValue = null) ->
    try
      @$get!
    catch
      defaultValue


  $batch-emit-updates: (fn) ->
    currentBatchId = (batchId += 1)
    @_should-queue-updates = yes
    fn()
    @_should-queue-updates = no
    while args = @_queued-updates.pop()
      @$emit-update ...args, currentBatchId


module.exports = StoreNode
