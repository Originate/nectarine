require! {
  './utils': {merge-objects}
  'react'
  './store-tree': StoreTree
}


module.exports = ({component, map-props}) ->

  class Connector extends react.Component

    @context-types =
      nectarine-store: react.PropTypes.instance-of(StoreTree)


    (props, context) ->
      super props, context
      @state = map-props(@context.nectarine-store, @props)
      @context.nectarine-store.$on-update @update


    componentWillUnmount: ->
      @context.nectarine-store.$off-update @update


    render: ->
      react.create-element(component, merge-objects(@props, @state))


    update: ~>
      @setState map-props(@context.nectarine-store, @props)
