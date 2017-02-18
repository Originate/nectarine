require! {
  './create': create-logger
}


describe 'create-logger' ->
  beforeEach ->
    @console =
      group-collapsed: sinon.spy()
      group-end: sinon.spy()
      log: sinon.spy()

  describe 'single update' ->
    error = new Error
    examples = [
      input:
        old-values: data: 'value'
        new-values: loading: true
      output:
        title: 'data => loading'
        old: '"value"'
        new: '<loading>'
    ,
      input:
        old-values: loading: true
        new-values: {error}
      output:
        title: 'loading => error'
        old: '<loading>'
        new: error
    ,
      input:
        old-values: {error}
        new-values: data: {a: 1}
      output:
        title: 'error => data'
        old: error
        new: {a: 1}
    ]
    examples.forEach ({input, output}, index) ->
      specify output.title, (done) ->
        onUpdate = create-logger {logger: @console}
        onUpdate do
          path: ['path', 'to', 'value']
          updates: [
            new-values: input.new-values
            old-values: input.old-values
            path: ['path', 'to', 'value']
          ]
        set-timeout ~>
          expect(@console.group-collapsed).to.have.been.calledWith "path.to.value: #{output.title}"
          expect(@console.log).to.have.been.calledWith '%c old:', 'color: red', output.old
          expect(@console.log).to.have.been.calledWith '%c new:', 'color: green', output.new
          expect(@console.group-end).to.have.been.called
          done()

  specify 'batched update' (done) ->
    onUpdate = create-logger {logger: @console}
    onUpdate do
      path: ['path', 'to', 'value']
      updates: [
        new-values: {data: 'a'}
        old-values: {data: null}
        path: ['path', 'to', 'value', 'key1']
      ,
        new-values: {data: 'b'}
        old-values: {data: null}
        path: ['path', 'to', 'value', 'key2']
      ,
        new-values: {data: 'c'}
        old-values: {data: null}
        path: ['path', 'to', 'value', 'key3', 'nestedKey']
      ]
    set-timeout ~>
      expect(@console.group-collapsed).to.have.been.calledOnce
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
      done()
