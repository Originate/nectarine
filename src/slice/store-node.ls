require! {
  'lodash.pull': pull
}


globalBatchId = 0


class StoreNode

  (@_schema) ->
    @_update-callbacks = []
    @_queued-updates = []


  $off-update: (callback) ->
    pull @_update-callbacks, callback


  $on-update: (callback) ->
    @_update-callbacks.push callback


  $emit-update: (newValue, oldValue, pathArray) ~>
    if @_should-queue-updates
      @_queued-updates.push [newValue, oldValue, pathArray]
    else
      for callback in @_update-callbacks
        callback ...


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
    globalBatchId += 1
    batchId = globalBatchId
    @_should-queue-updates = yes
    fn()
    @_should-queue-updates = no
    while args = @_queued-updates.shift()
      @$emit-update ...args, {batchId, batchPath: @$get-path!}


module.exports = StoreNode
