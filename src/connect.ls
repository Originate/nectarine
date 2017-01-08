require! {
  'lodash.assign': assign
  'react'
}


module.exports = (component, map-props) ->

  class Connector extends react.Component

    @context-types =
      slice: react.PropTypes.any


    (props, context) ->
      super props, context
      @state = map-props @context.slice
      @unregister = @context.slice.$on-update ~> @setState map-props @context.slice


    componentWillUnmount: ->
      @unregister!


    render: ->
      react.create-element(component, assign({}, @props, @state))
