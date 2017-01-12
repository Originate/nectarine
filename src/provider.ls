require! {
  'react'
}


module.exports = ({component, slice}) ->

  class Provider extends react.Component

    @child-context-types =
      slice: react.PropTypes.any


    get-child-context: ->
      {slice}


    render: ->
      react.create-element component
