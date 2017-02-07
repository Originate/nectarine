require! {
  './slice-data': SliceData
}


create-slice = (opts) ->
  new SliceData opts


module.exports = create-slice
