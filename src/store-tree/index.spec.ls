require! {
  './schema-placeholder': {create-placeholder: __}
  './spec/test-cases'
  './store-leaf': StoreLeaf
  './': StoreTree
}


create-tree = (child-mapping) ->
  tree-path = <[path to tree]>
  children = {}
  for own key, schema of child-mapping
    children[key] = new StoreLeaf {path: tree-path.concat(key), schema}
  new StoreTree {children, path: tree-path}


describe 'StoreTree' ->

  describe '$debug' ->

    test-cases '' [
      -> @tree = create-tree name: __, email: __
      -> @tree = create-tree name: __!, email: __!
    ] ->

      specify 'returns the debugged mapping of its children' ->
        @tree.name.$set 'Alice'
        @tree.email.$set-error Error 'Failed to get email'
        expect(@tree.$debug!).to.eql do
          name: {data: 'Alice', loading: false, error: null}
          email: {data: null, loading: false, error: Error 'Failed to get email'}


  describe '$from-promise' ->

    before-each ->
      @tree = create-tree name: __, email: __
      @promise = @tree.$from-promise new Promise (@resolve, @reject) ~>
      null

    specify 'initially sets loading on itself and all sub-nodes' ->
      expect(@tree.$is-loading!).to.be.true
      expect(@tree.name.$is-loading!).to.be.true
      expect(@tree.email.$is-loading!).to.be.true

    specify 'it returns a promise' ->
      expect(@promise.then).to.be.a \function

    context 'resolved' ->

      before-each ->
        set-timeout ~> @resolve name: 'Alice', email: 'alice@example.com'
        @promise

      specify 'it removes loading' ->
        expect(@tree.$is-loading!).to.be.false
        expect(@tree.name.$is-loading!).to.be.false
        expect(@tree.email.$is-loading!).to.be.false

      specify 'it sets data' ->
        expect(@tree.name.$get!).to.equal 'Alice'
        expect(@tree.email.$get!).to.equal 'alice@example.com'

    context 'resolved with bad type' ->

      before-each ->
        set-timeout ~> @resolve 'some string'
        @promise.catch(@catch-spy = sinon.spy!)

      specify 'it returns a failing promise' ->
        expect(@catch-spy).to.have.been.called-once
        expect(@catch-spy.first-call.args[0]).to.eql Error '$from-promise: called on a tree but promise resolved to a String'

      specify 'it removes loading' ->
        expect(@tree.$is-loading!).to.be.false
        expect(@tree.name.$is-loading!).to.be.false
        expect(@tree.email.$is-loading!).to.be.false

    context 'rejected' ->

      before-each ->
        set-timeout ~> @reject @err = Error 'Failed to get user'
        @promise.catch(@catch-spy = sinon.spy!)

      specify 'it passes the error' ->
        expect(@catch-spy).to.have.been.called-once
        expect(@catch-spy.first-call.args[0]).to.equal @err

      specify 'it removes loading' ->
        expect(@tree.$is-loading!).to.be.false
        expect(@tree.name.$is-loading!).to.be.false
        expect(@tree.email.$is-loading!).to.be.false

      specify 'it sets error' ->
        expect(@tree.name.$get-error!).to.equal @err
        expect(@tree.email.$get-error!).to.equal @err


  describe '$get' ->

    test-cases '' [
      -> @tree = create-tree name: __, email: __
      -> @tree = create-tree name: __!, email: __!
    ] ->

      specify 'throws an error when attempting to access data with error' ->
        @tree.name.$set 'Alice'
        @tree.email.$set-error Error 'Failed to get email'
        expect(~> @tree.$get!).to.throw 'Error getting `path.to.tree.email`: has error "Failed to get email"'

      specify 'throws an error when attempting to access loading data' ->
        @tree.name.$set 'Alice'
        @tree.email.$set-loading!
        expect(~> @tree.$get!).to.throw 'Error getting `path.to.tree.email`: is loading'


  describe '$get-or-else' ->
    test-cases '' [
      -> @tree = create-tree name: __, email: __
      -> @tree = create-tree name: __!, email: __!
    ] ->
      describe 'without default' ->
        specify 'returns the data if present' ->
          @tree.name.$set 'Alice'
          expect(@tree.$get-or-else!).to.eql name: 'Alice', email: null

        specify 'returns null if is loading' ->
          @tree.name.$set-loading!
          expect(@tree.$get-or-else!).to.be.null

        specify 'returns null if has error', ->
          @tree.name.$set-error Error 'Failed to get name'
          expect(@tree.$get-or-else!).to.be.null

      describe 'with default' ->
        before-each ->
          @defaultValue = name: 'Bob', email: 'bob@example.com'

        specify 'returns the data if present' ->
          @tree.name.$set 'Alice'
          expect(@tree.$get-or-else @defaultValue).to.eql name: 'Alice', email: null

        specify 'returns the default if is loading' ->
          @tree.name.$set-loading!
          expect(@tree.$get-or-else @defaultValue).to.eql name: 'Bob', email: 'bob@example.com'

        specify 'returns the default if has error', ->
          @tree.name.$set-error Error 'Failed to get name'
          expect(@tree.$get-or-else @defaultValue).to.eql name: 'Bob', email: 'bob@example.com'


  describe '$has-data' ->
    test-cases '' [
      -> @tree = create-tree name: __, email: __
      -> @tree = create-tree name: __!, email: __!
    ] ->

      specify 'returns false if data is null' ->
        expect(@tree.$has-data!).to.be.false

      specify 'returns true if any child has data' ->
        @tree.name.$set 'Alice'
        expect(@tree.$has-data!).to.be.true

      specify 'returns false if is loading' ->
        @tree.name.$set-loading!
        @tree.email.$set 'alice@example.com'
        expect(@tree.$has-data!).to.be.false

      specify 'returns false if has error', ->
        @tree.name.$set-error Error 'Failed to get name'
        @tree.email.$set 'alice@example.com'
        expect(@tree.$has-data!).to.be.false


  describe '$on-update' ->

    before-each ->
      @tree = create-tree do
        name: __ initial-value: 'Alice'
        email: __
      @tree.$on-update @tree-update-spy = sinon.spy!

    specify 'does not call callbacks if nothing updates' ->
      expect(@tree-update-spy).to.not.have.been.called

    specify 'supports multiple callbacks' ->
      @tree.$on-update tree-update-spy2 = sinon.spy!
      @tree.name.$set 'Bob'
      expect(@tree-update-spy).to.have.been.called-once
      expect(tree-update-spy2).to.have.been.called-once

    specify 'supports removing callbacks' ->
      @tree.$off-update @tree-update-spy
      @tree.name.$set 'Bob'
      expect(@tree-update-spy).to.not.have.been.called

    test-cases 'triggers when set* methods are called' {
      $set: ->
        @tree.name.$set('Bob')
        @new-values = data: 'Bob', loading: no, error: null
      $set-loading: ->
        @tree.name.$set-loading!
        @new-values = data: null, loading: yes, error: null
      $set-error: ->
        @tree.name.$set-error err = Error 'some error'
        @new-values = data: null, loading: no, error: err
    } ->
      specify 'calls callbacks' ->
        expect(@tree-update-spy).to.have.been.called-once

      specify 'calls with new-values, old-values, path' ->
        expect(@tree-update-spy).to.have.been.called-with do
          path: <[path to tree name]>
          updates: [{
            @new-values
            old-values: {data: 'Alice', loading: false, error: null}
            path: <[path to tree name]>
          }]


  describe '$reset' ->

    test-cases 'resetting leaves' [
      -> @tree = create-tree name: __, email: __
      -> @tree = create-tree name: __!, email: __!
    ] ->

      specify 'resets data to the initial value' ->
        @tree.name.$set 'Alice'
        @tree.$reset()
        expect(@tree.name.$get!).to.be.null

      specify 'sets loading to false on each leaf' ->
        @tree.name.$set-loading yes
        @tree.$reset()
        expect(@tree.name.$is-loading!).to.be.false

      specify 'called with false sets loading to false on all leaves' ->
        @tree.name.$set-error Error 'Some error'
        @tree.$reset()
        expect(@tree.name.$get-error!).to.be.null

      specify 'batches updates', ->
        @tree.$set name: 'Bob', email: 'bob@example.com'
        @tree.$on-update update-spy = sinon.spy()
        @tree.$reset!
        expect(update-spy).to.have.been.called-with do
          path: <[path to tree]>
          updates: [
            new-values: {data: null, loading: false, error: null}
            old-values: {data: 'Bob', loading: false, error: null}
            path: <[path to tree name]>
          ,
            new-values: {data: null, loading: false, error: null}
            old-values: {data: 'bob@example.com', loading: false, error: null}
            path: <[path to tree email]>
          ]


  describe '$set' ->

    test-cases 'setting values' [
      -> @tree = create-tree name: __, email: __
      -> @tree = create-tree name: __!, email: __!
    ] ->

      specify 'sets the values on the tree' ->
        @tree.$set name: 'Alice', email: 'alice@example.com'
        expect(@tree.$get!).to.eql name: 'Alice', email: 'alice@example.com'

      specify 'sets loading to false for all leaves' ->
        @tree.name.$set-loading!
        @tree.email.$set-loading!
        @tree.$set name: 'Alice', email: 'alice@example.com'
        expect(@tree.$is-loading!).to.be.false
        expect(@tree.name.$is-loading!).to.be.false
        expect(@tree.email.$is-loading!).to.be.false

      specify 'sets error to null' ->
        @tree.name.$set-error Error 'Failed to get name'
        @tree.email.$set-error Error 'Failed to get email'
        @tree.$set name: 'Alice', email: 'alice@example.com'
        expect(@tree.$get-error!).to.be.null
        expect(@tree.name.$get-error!).to.be.null
        expect(@tree.email.$get-error!).to.be.null

      specify 'ignores extra keys' ->
        @tree.$set name: 'Alice', foo: 'bar'
        expect(@tree.$get!).to.eql name: 'Alice', email: null

      specify 'setting a non-object on a parent throws an error' ->
        expect(~> @tree.$set 'Alice').to.throw 'calling $set on a tree must be called with an object'

      specify 'batches updates', ->
        @tree.$on-update update-spy = sinon.spy()
        @tree.$set name: 'Alice', email: 'alice@example.com'
        expect(update-spy).to.have.been.called-with do
          path: <[path to tree]>
          updates: [
            new-values: {data: 'Alice', loading: false, error: null}
            old-values: {data: null, loading: false, error: null}
            path: <[path to tree name]>
          ,
            new-values: {data: 'alice@example.com', loading: false, error: null}
            old-values: {data: null, loading: false, error: null}
            path: <[path to tree email]>
          ]


    test-cases 'setting values on parents of leaves with specified type' [
      -> @tree = create-tree name: __ initial-value: 123
      -> @tree = create-tree name: __ type: Number
      -> @tree = create-tree name: __ type: \number
    ] ->

      specify 'successfuly sets value if type matches' ->
        @tree.$set name: 456
        expect(@tree.name.$get!).to.equal 456

      specify 'throws an error if a value is the wrong type' ->
        expect(~>
          @tree.$set name: 'Not a number'
        ).to.throw 'Error setting `path.to.tree.name`: "Not a number" (type String) does not match required type Number'


    test-cases 'required isnt true' [
      -> @tree = create-tree name: __
      -> @tree = create-tree name: __!
      -> @tree = create-tree name: __ required: no
    ] ->
      before-each -> @tree.$set name: 'fizz'

      specify 'allows setting null with a deeply nested object to the leaf' ->
        @tree.$set name: null
        expect(@tree.name.$get!).to.be.null

      specify 'allows setting null on a parent' ->
        @tree.$set null
        expect(@tree.name.$get!).to.be.null


    describe 'required is true' ->

      before-each ->
        @tree = create-tree name: __ required: yes, initial-value: 'fizz'

      specify 'throws an error with a deeply nested object to the leaf' ->
        @tree.$set name: 'buzz'
        expect(~> @tree.$set name: null).to.throw 'Error setting `path.to.tree.name`: null fails non-null constraint'
        expect(@tree.name.$get!).to.equal 'buzz'

      specify 'throws an error setting null on a parent' ->
        @tree.$set name: 'buzz'
        expect(~> @tree.$set null).to.throw 'Error setting `path.to.tree.name`: null fails non-null constraint'
        expect(@tree.name.$get!).to.equal 'buzz'


  describe '$set-error' ->

    test-cases 'setting errors on trees' [
      -> @tree = create-tree name: __, email: __
      -> @tree = create-tree name: __!, email: __!
    ] ->

      specify 'trees initially do not have an error' ->
        expect(@tree.$get-error!).to.be.null

      specify 'sets an error on all leaves' ->
        err = Error 'Error getting name'
        @tree.$set-error err
        expect(@tree.$get-error!).to.equal err
        expect(@tree.name.$get-error!).to.equal err
        expect(@tree.email.$get-error!).to.equal err

      specify 'sets loading to false on all leaves' ->
        @tree.$set-loading!
        @tree.$set-error Error 'Some error'
        expect(@tree.$is-loading!).to.be.false
        expect(@tree.name.$is-loading!).to.be.false
        expect(@tree.email.$is-loading!).to.be.false

      specify 'batches updates', ->
        err = new Error 'Some error'
        @tree.$on-update update-spy = sinon.spy()
        @tree.$set-error err
        expect(update-spy).to.have.been.called-with do
          path: <[path to tree]>
          updates: [
            new-values: {data: null, loading: false, error: err}
            old-values: {data: null, loading: false, error: null}
            path: <[path to tree name]>
          ,
            new-values: {data: null, loading: false, error: err}
            old-values: {data: null, loading: false, error: null}
            path: <[path to tree email]>
          ]


  describe '$set-loading' ->

    test-cases 'setting loading on leaves' [
      -> @tree = create-tree name: __, email: __
      -> @tree = create-tree name: __!, email: __!
    ] ->

      specify 'trees are initially not loading' ->
        expect(@tree.$is-loading!).to.be.false
        expect(@tree.name.$is-loading!).to.be.false

      specify 'called without arguments sets loading on all leaves' ->
        @tree.$set-loading!
        expect(@tree.$is-loading!).to.be.true
        expect(@tree.name.$is-loading!).to.be.true

      specify 'called with true sets loading on leaves' ->
        @tree.$set-loading yes
        expect(@tree.$is-loading!).to.be.true
        expect(@tree.name.$is-loading!).to.be.true

      specify 'called with false sets loading to false on all leaves' ->
        @tree.$set-loading!
        @tree.$set-loading no
        expect(@tree.$is-loading!).to.be.false
        expect(@tree.name.$is-loading!).to.be.false

      specify 'sets error to null' ->
        @tree.name.$set-error Error 'Some error'
        @tree.$set-loading!
        expect(@tree.name.$get-error!).to.be.null

      specify 'batches updates', ->
        @tree.$on-update update-spy = sinon.spy()
        @tree.$set-loading!
        expect(update-spy).to.have.been.called-with do
          path: <[path to tree]>
          updates: [
            new-values: {data: null, loading: true, error: null}
            old-values: {data: null, loading: false, error: null}
            path: <[path to tree name]>
          ,
            new-values: {data: null, loading: true, error: null}
            old-values: {data: null, loading: false, error: null}
            path: <[path to tree email]>
          ]
