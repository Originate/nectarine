require! {
  'react'
}


module.exports = ({component, store}) ->

  class Provider extends react.Component

    @child-context-types =
      store: react.PropTypes.any


    get-child-context: ->
      {store}


    render: ->
      react.create-element component
