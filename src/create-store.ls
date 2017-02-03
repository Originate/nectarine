require! {
  './store-tree/helpers': {build-store-node}
  './store-tree': StoreTree
}


create-store = (slice-mapping, {dependencies} = {}) ->
  children = {}
  for own key, {actions, schema} of slice-mapping
    children[key] = build-store-node {actions, path: [key], schema}
  new StoreTree {children, dependencies, isRoot: true, path: []}


module.exports = create-store
