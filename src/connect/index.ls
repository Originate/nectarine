require! {
  '../utils': {merge-objects}
  'react'
  '../store-tree': StoreTree
  './connect-bind-props'
  './connect-map-props'
}


module.exports = ({bind-props, component, map-props}) ->
  switch
  | bind-props => connectBindProps {component, bind-props}
  | map-props  => connectMapProps {component, map-props}
  | otherwise  => throw new Error 'connect: bindProps or mapProps must be supplied'
