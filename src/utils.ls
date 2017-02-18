require! {
  'prelude-ls': {each, obj-to-pairs}
}


assign = (...objs) ->
  result = {}
  objs |> each |> obj-to-pairs |> each ([key, value]) -> result[key] = value
  result


module.exports = {assign}
