require! {
  'prelude-ls': {each, obj-to-pairs}
}


unionObjects = (...objs) ->
  result = {}
  for obj in objs
    for key, value of obj
      result[key] = value
  result


module.exports = {unionObjects}
