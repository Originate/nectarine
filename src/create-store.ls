require! {
  './slice/helpers': {build-store-node}
}


create-store = (slices, {dependencies} = {}) ->
  children = {}
  for own key, {actions, schema} of slices
    children[key] = build-store-node {actions, path: [key], schema}
  new StoreTree {children, dependencies, isRoot: true, path: []}


module.exports = create-store
