require! {
  'lodash.pull': pull
}


globalBatchId = 0


class StoreNode

  ({actions, get-action-context: @_get-action-context, path: @_path}) ->
    @_update-callbacks = []
    @_queued-updates = []

    if actions?
      for own actionName, action-fn of actions
        @_bind-action action-name, action-fn


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
    @_path


  $get-path-string: ->
    @$get-path!.join '.'


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
    for args in @_queued-updates
      @$emit-update ...args, {batchId, batchPath: @$get-path!}
    @_queued-updates = []


  _bind-action: (action-name, action-fn) ->
    @[action-name] = (...args) ~>
      context = {slice: this, ...@_get-action-context!}
      action-fn.apply context, args


module.exports = StoreNode
