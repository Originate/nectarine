require! {
  'lodash.assign': assign
  './create': create-logger
}


describe 'create-logger' ->
  beforeEach ->
    @console =
      group-collapsed: sinon.spy()
      group-end: sinon.spy()
      log: sinon.spy()

  error = new Error
  examples = [
    input:
      old-value: data: 'value'
      new-value: loading: true
    output:
      title: 'data => loading'
      old: '"value"'
      new: '<loading>'
  ,
    input:
      old-value: loading: true
      new-value: {error}
    output:
      title: 'loading => error'
      old: '<loading>'
      new: error
  ,
    input:
      old-value: {error}
      new-value: data: {a: 1}
    output:
      title: 'error => data'
      old: error
      new: {a: 1}
  ]
  examples.forEach ({input, output}, index) ->
    specify output.title, (done) ->
      onUpdate = create-logger {logger: @console}
      onUpdate input.new-value, input.old-value, ['path', 'to', 'value']
      set-timeout ~>
        expect(@console.group-collapsed).to.have.been.calledWith "path.to.value: #{output.title}"
        expect(@console.log).to.have.been.calledWith '%c old:', 'color: red', output.old
        expect(@console.log).to.have.been.calledWith '%c new:', 'color: green', output.new
        expect(@console.group-end).to.have.been.called
        done()

  describe 'batching' ->
    specify 'batches events with the same transition type and common parent', (done) ->
      onUpdate = create-logger {logger: @console}
      meta = {batch-id: 1, batch-path: ['path', 'to', 'value']}
      onUpdate {data: 'a'}, {data: null}, ['path', 'to', 'value', 'key1'], meta
      onUpdate {data: 'b'}, {data: null}, ['path', 'to', 'value', 'key2'], meta
      onUpdate {data: 'c'}, {data: null}, ['path', 'to', 'value', 'key3', 'nestedKey'], meta
      onUpdate {data: 'd'}, {data: null}, ['path', 'to', 'other']
      set-timeout ~>
        expect(@console.group-collapsed).to.have.been.calledTwice
        expect(@console.group-collapsed).to.have.been.calledWith "path.to.value: data => data"
        expect(@console.log).to.have.been.calledWith '%c old:', 'color: red',
          key1: null
          key2: null
          key3: nestedKey: null
        expect(@console.log).to.have.been.calledWith '%c new:', 'color: green',
          key1: 'a'
          key2: 'b'
          key3: nestedKey: 'c'
        expect(@console.group-end).to.have.been.called

        expect(@console.group-collapsed).to.have.been.calledWith "path.to.other: data => data"
        expect(@console.log).to.have.been.calledWith '%c old:', 'color: red', null
        expect(@console.log).to.have.been.calledWith '%c new:', 'color: green', '"d"'
        expect(@console.group-end).to.have.been.called
        done()
