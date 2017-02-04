require! {
  './helpers': {merge-updates}
}


describe 'helpers' ->
  beforeEach ->
    @console = {}

  describe 'mergeUpdates' ->
    error = new Error 'Some error'
    examples = [
      description: 'one update'
      input: [
        new-value: {data: 'value1'}
        old-value: {data: null}
        path-array: ['path', 'to', 'value', 'key1']
      ]
      output:
        new-value: {data: 'value1'}
        old-value: {data: null}
        path-array: ['path', 'to', 'value', 'key1']
    ,
      description: 'multiple updates (data => data)'
      input: [
        meta: {batchPath: ['path', 'to', 'value']}
        new-value: {data: 'value1'}
        old-value: {data: null}
        path-array: ['path', 'to', 'value', 'key1']
      ,
        meta: {batchPath: ['path', 'to', 'value']}
        new-value: {data: 'value2'}
        old-value: {data: null}
        path-array: ['path', 'to', 'value', 'key2']
      ]
      output:
        new-value: data: {key1: 'value1', key2: 'value2'}
        old-value: data: {key1: null, key2: null}
        path-array: ['path', 'to', 'value']
    ,
      description: 'multiple updates (loading => error)'
      input: [
        meta: {batchPath: ['path', 'to', 'value']}
        new-value: {error}
        old-value: {loading: true}
        path-array: ['path', 'to', 'value', 'key1']
      ,
        meta: {batchPath: ['path', 'to', 'value']}
        new-value: {error}
        old-value: {loading: true}
        path-array: ['path', 'to', 'value', 'key2']
      ]
      output:
        new-value: {error}
        old-value: {loading: true}
        path-array: ['path', 'to', 'value']
    ]
    examples.forEach ({description, input, output}) ->
      it description, ->
        expect(merge-updates(input)).to.eql output
