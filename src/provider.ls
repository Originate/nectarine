require! {
  'react'
  './slice': Slice
}


class Provider extends react.Component

  @child-context-types =
    slice: react.PropTypes.instance-of(Slice)


  @prop-types =
    slice: react.PropTypes.instance-of(Slice)
    children: react.PropTypes.element.isRequired


  get-child-context: ->
    {slice: @props.slice}


  render: ->
    @props.children


module.exports = Provider
