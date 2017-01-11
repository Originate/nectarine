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
      @context.slice.$on-update @update


    componentWillUnmount: ->
      @context.slice.$off-update @update


    render: ->
      react.create-element(component, assign({}, @props, @state))


    update: ~>
      @setState map-props @context.slice
