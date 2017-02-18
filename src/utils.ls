require! {
  'prelude-ls': {each, obj-to-pairs}
}


merge-objects = (...objs) ->
  result = {}
  for obj in objs
    for own key, value of obj
      result[key] = value
  result


module.exports = {merge-objects}
