require! {
  '../store-tree/store-node': StoreNode
  '../store-tree': StoreTree
  '../utils': {merge-objects}
  'prelude-ls': {Obj: {each}}
  'react'
}


module.exports = ({component, bind-props}) ->

  class Connector extends react.Component

    @context-types =
      nectarine-store: react.PropTypes.instance-of(StoreTree)


    (props, context) ->
      super props, context
      @_bind props
      @state = @_computeState!


    componentWillUnmount: ->
      @_unbind!


    componentWillReceiveProps: (nextProps) ->
      @_unbind!
      @_bind nextProps


    render: ->
      react.create-element(component, merge-objects(@props, @state))


    update: ~>
      @setState @_computeState!


    _bind: (props) ->
      @mapping = bind-props @context.nectarine-store, props
      @mapping |> each ~> if it instanceof StoreNode then it.$on-update @update


    _computeState: ->
      result = isLoading: false, errors: []
      for own key, value of @mapping
        if value instanceof StoreNode
          result[key] = value.$getOrElse()
          if value.$isLoading()
            result.isLoading = true
          if error = value.$getError()
            result.errors.push error
        else
          result[key] = value
      result


    _unbind: ->
      @mapping |> each ~> if it instanceof StoreNode then it.$off-update @update
