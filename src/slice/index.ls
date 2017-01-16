require! {
  './schema-placeholder': SchemaPlaceholder
  './store-tree': StoreTree
}


class Slice extends StoreTree

  ({schema: get-schema, actions}, path) ->
    schema = get-schema SchemaPlaceholder.create-placeholder
    super schema, path

    if actions?
      for own actionName, action-fn of actions
        @_bind-action action-name, action-fn



  _bind-action: (action-name, action-fn) ->
    if @[actionName]
      throw new Error "Failed to create slice \"#{@$get-path-string!}\": Action \"#{actionName}\" would override schema"

    @[actionName] = (...args) ~>
      context = {slice: this, ...@_dependencies}
      action-fn.apply context, args


module.exports = Slice
