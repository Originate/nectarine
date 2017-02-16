require! {
  'lodash/isEqual'
  'lodash/set'
}


get-merged-value = ({key, path, updates}) ->
  if get-value-type(updates[0][key]) in ['error', 'loading']
    updates[0][key]
  else
    path-length = path.length
    merged = {}
    for update in updates
      set merged, update.path.slice(path-length), update[key].data
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
  if updates.length is 1 and isEqual(path, updates[0].path)
    updates[0]
  else
    new-values: get-merged-value {key: 'newValues', path, updates}
    old-values: get-merged-value {key: 'oldValues', path, updates}
    path: path


module.exports = {get-transition, get-value, merge-updates}
