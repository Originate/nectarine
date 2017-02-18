require! {
  'prelude-ls': {all}
}


are-paths-equal = (path1, path2) ->
  path1.length is path2.length and
    [0 to path1.length] |> all -> path1[it] is path2[it]


get-merged-value = ({key, path, updates}) ->
  if get-value-type(updates[0][key]) in ['error', 'loading']
    updates[0][key]
  else
    path-length = path.length
    merged = {}
    for update in updates
      set-value-at-path merged, update.path.slice(path-length), update[key].data
    data: merged


get-transition = ({new-values, old-values}) ->
  "#{get-value-type old-values} => #{get-value-type new-values}"


get-value = ({data, loading, error}) ->
  if loading
    '<loading>'
  else if error
    error
  else
    if typeof! data is 'String'
      JSON.stringify data
    else
      data


get-value-type = ({data, loading, error}) ->
  if loading
    'loading'
  else if error
    'error'
  else
    'data'


merge-updates = ({path, updates}) ->
  if updates.length is 1 and are-paths-equal(path, updates[0].path)
    updates[0]
  else
    new-values: get-merged-value {key: 'newValues', path, updates}
    old-values: get-merged-value {key: 'oldValues', path, updates}
    path: path


set-value-at-path = (obj, path, value) ->
  for key, index in path
    if index is path.length - 1
      obj[key] = value
    else
      obj[key] or= {}
      obj = obj[key]


module.exports = {get-transition, get-value, merge-updates}
