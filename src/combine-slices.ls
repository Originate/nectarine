require! {
  './slice/store-tree': StoreTree
}


combine-slices = (slices) ->
  new StoreTree slices, []


module.exports = combine-slices
