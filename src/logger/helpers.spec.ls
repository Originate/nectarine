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
      input:
        path: ['path', 'to', 'value', 'key1']
        updates: [
          new-values: {data: 'value1'}
          old-values: {data: null}
          path: ['path', 'to', 'value', 'key1']
        ]
      output:
        new-values: {data: 'value1'}
        old-values: {data: null}
        path: ['path', 'to', 'value', 'key1']
    ,
      description: 'multiple updates (data => data)'
      input:
        path: ['path', 'to', 'value']
        updates: [
          new-values: {data: 'value1'}
          old-values: {data: null}
          path: ['path', 'to', 'value', 'key1']
        ,
          new-values: {data: 'value2'}
          old-values: {data: null}
          path: ['path', 'to', 'value', 'key2']
        ]
      output:
        new-values: data: {key1: 'value1', key2: 'value2'}
        old-values: data: {key1: null, key2: null}
        path: ['path', 'to', 'value']
    ,
      description: 'multiple updates (loading => error)'
      input:
        path: ['path', 'to', 'value']
        updates: [
          new-values: {error}
          old-values: {loading: true}
          path: ['path', 'to', 'value', 'key1']
        ,
          new-values: {error}
          old-values: {loading: true}
          path: ['path', 'to', 'value', 'key2']
        ]
      output:
        new-values: {error}
        old-values: {loading: true}
        path: ['path', 'to', 'value']
    ]
    examples.forEach ({description, input, output}) ->
      it description, ->
        expect(merge-updates(input)).to.eql output
