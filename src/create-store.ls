require! {
  './store-tree/helpers': {build-store-node}
}


create-store = (slice-mapping, {dependencies} = {}) ->
  get-action-context = -> {store, ...dependencies}
  store = build-store-node {get-action-context, path: [], schema: slice-mapping}
  store


module.exports = create-store
