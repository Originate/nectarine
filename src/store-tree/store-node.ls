require! {
  'prelude-ls': {reject}
}


class StoreNode

  ({actions, get-action-context: @_get-action-context, path: @_path}) ->
    @_update-callbacks = []
    @_queued-updates = []

    if actions?
      for own actionName, action-fn of actions
        @_bind-action action-name, action-fn


  $batch-emit-updates: (fn) ->
    @_should-queue-updates = yes
    fn()
    @_should-queue-updates = no
    updates = []
    for arg in @_queued-updates
      updates = updates.concat arg.updates
    @_queued-updates = []
    @$emit-update {path: @$get-path!, updates}


  $emit-update: (arg) ~>
    if @_should-queue-updates
      @_queued-updates.push arg
    else
      for callback in @_update-callbacks
        callback ...


  $get-or-else: (defaultValue = null) ->
    try
      @$get!
    catch
      defaultValue


  $get-path: ->
    @_path


  $get-path-string: ->
    @$get-path!.join '.'


  $off-update: (callback) ->
    @_update-callbacks = @_update-callbacks |> reject -> it is callback


  $on-update: (callback) ->
    @_update-callbacks.push callback


  _bind-action: (action-name, action-fn) ->
    @[action-name] = (...args) ~>
      context = {slice: this, ...@_get-action-context!}
      action-fn.apply context, args


module.exports = StoreNode
