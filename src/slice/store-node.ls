require! {
  'lodash.pull': pull
}


class StoreNode

  ({path: @_path}) ->
    @_update-callbacks = []


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


  $set-store: (@_store) ->


module.exports = StoreNode
