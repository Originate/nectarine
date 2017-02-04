require! {
  'lodash.set': set
}


get-merged-value = (updates, key) ->
  if get-value-type(updates[0][key]) in ['error', 'loading']
    updates[0][key]
  else
    batch-path-length = updates[0].meta.batch-path.length
    merged = {}
    for update in updates
      set merged, update.path-array.slice(batch-path-length), update[key].data
    data: merged


get-transition = ({new-value, old-value}) ->
  "#{get-value-type old-value} => #{get-value-type new-value}"


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


merge-updates = (updates) ->
  if updates.length is 1
    updates[0]
  else
    new-value: get-merged-value updates, 'newValue'
    old-value: get-merged-value updates, 'oldValue'
    path-array: updates[0].meta.batch-path


module.exports = {get-transition, get-value, merge-updates}
