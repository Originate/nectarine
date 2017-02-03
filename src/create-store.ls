require! {
  './store-tree/helpers': {build-store-node}
}


create-store = (slice-mapping, {dependencies} = {}) ->
  build-store-node {dependencies, isRoot: true, path: [], schema: slice-mapping}


module.exports = create-store
