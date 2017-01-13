require! {
  'lodash.assign': assign
  'react'
}


module.exports = ({component, map-props}) ->

  class Connector extends react.Component

    @context-types =
      store: react.PropTypes.any


    (props, context) ->
      super props, context
      @state = map-props @context.store
      @context.store.$on-update @update


    componentWillUnmount: ->
      @context.store.$off-update @update


    render: ->
      react.create-element(component, assign({}, @props, @state))


    update: ~>
      @setState map-props @context.store
