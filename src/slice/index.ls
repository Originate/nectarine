require! {
  './schema-placeholder': SchemaPlaceholder
  './store-tree': StoreTree
}


class Slice extends StoreTree

  ({schema, actions, dependencies}) ->
    if typeof schema is 'function'
      schema = schema SchemaPlaceholder.create-placeholder
    super schema

    if actions?
      for own actionName, action-fn of actions
        @_bind-action action-name, action-fn

    if dependencies?
      @$inject dependencies


  _bind-action: (action-name, action-fn) ->
    if @[actionName]
      throw new Error "Failed to create slice: Action \"#{actionName}\" would override schema"

    @[actionName] = (...args) ~>
      root-slice = @$get-root!
      context = {root-slice, slice: this, ...root-slice._dependencies}
      action-fn.apply context, args


module.exports = Slice
