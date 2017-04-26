require! {
  '../store-tree': StoreTree
  '../utils': {merge-objects}
  'prop-types': PropTypes
  'react'
}


module.exports = ({component, map-props}) ->

  class Connector extends react.Component

    @context-types =
      nectarine-store: PropTypes.instance-of(StoreTree)


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
