require! {
  'react'
  './store-tree': StoreTree
}


class Provider extends react.Component

  @child-context-types =
    nectarine-store: react.PropTypes.instance-of(StoreTree)


  @prop-types =
    nectarine-store: react.PropTypes.instance-of(StoreTree)
    children: react.PropTypes.element.isRequired


  get-child-context: ->
    {nectarine-store: @props.store}


  render: ->
    @props.children


module.exports = Provider
