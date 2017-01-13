require! {
  './slice/store-tree': StoreTree
}


combine-slices = (slices) ->
  for key, value of slices
    value.$prepend-to-path key
  new StoreTree slices, []


module.exports = combine-slices
