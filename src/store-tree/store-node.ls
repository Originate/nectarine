require! {
  'lodash.pull': pull
}


class StoreNode

  ({actions, get-action-context: @_get-action-context, path: @_path}) ->
    @_update-callbacks = []

    if actions?
      for own actionName, action-fn of actions
        @_bind-action action-name, action-fn


  $off-update: (callback) ->
    pull @_update-callbacks, callback


  $on-update: (callback) ->
    @_update-callbacks.push callback


  $emit-update: (...args) ~>
    for callback in @_update-callbacks
      callback.apply {}, args


  $get-path: ->
    @_path


  $get-path-string: ->
    @$get-path!.join '.'


  $get-or-else: (defaultValue = null) ->
    try
      @$get!
    catch
      defaultValue


  _bind-action: (action-name, action-fn) ->
    @[action-name] = (...args) ~>
      context = {slice: this, ...@_get-action-context!}
      action-fn.apply context, args


module.exports = StoreNode
