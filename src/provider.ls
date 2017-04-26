require! {
  './store-tree': StoreTree
  'prop-types': PropTypes
  'react'
}


class Provider extends react.Component

  @child-context-types =
    nectarine-store: PropTypes.instance-of(StoreTree)


  @prop-types =
    nectarine-store: PropTypes.instance-of(StoreTree)
    children: PropTypes.element.isRequired


  get-child-context: ->
    {nectarine-store: @props.store}


  render: ->
    @props.children


module.exports = Provider
