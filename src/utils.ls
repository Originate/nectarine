require! {
  'prelude-ls': {each, obj-to-pairs}
}


assign = (...objs) ->
  result = {}
  for obj in objs
    obj |> obj-to-pairs |> each ([key, value]) -> result[key] = value
  result


module.exports = {assign}
