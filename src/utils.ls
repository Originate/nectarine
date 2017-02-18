require! {
  'prelude-ls': {each, obj-to-pairs}
}


assign = (...objs) ->
  result = {}
  for obj in objs
    for key, value of obj
      result[key] = value
  result


module.exports = {assign}
