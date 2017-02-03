require! {
  './schema-placeholder': {create-placeholder: __}
  './spec/test-cases'
  './store-leaf': StoreLeaf
  './store-tree': StoreTree
}


build-tree = (child-schemas, path = []) ->
  children = {}
  for own key, value of child-schemas
    child-path = path.concat key
    children[key] = if typeof value is 'object'
      build-tree value, child-path
    else
      new StoreLeaf {path: child-path, schema: value}

  new StoreTree {children, path: tree-path}


describe 'StoreTree' ->

  describe '$get' ->

    test-cases '' [
      -> @tree = build-tree name: __, email: __
      -> @tree = build-tree name: __!, email: __!
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
      -> @tree = build-tree name: __, email: __
      -> @tree = build-tree name: __, email: __
    ] ->
      describe 'without default' ->
        specify 'returns the data if present' ->
          @store.current-user.name.$set 'Alice'
          expect(@store.current-user.$get-or-else!).to.eql name: 'Alice', email: null

        specify 'returns null if is loading' ->
          @store.current-user.name.$set-loading!
          expect(@store.current-user.$get-or-else!).to.be.null

        specify 'returns null if has error', ->
          @store.current-user.name.$set-error Error 'Failed to get name'
          expect(@store.current-user.$get-or-else!).to.be.null

      describe 'with default' ->
        before-each ->
          @defaultValue = name: 'Bob', email: 'bob@example.com'

        specify 'returns the data if present' ->
          @store.current-user.name.$set 'Alice'
          expect(@store.current-user.$get-or-else @defaultValue).to.eql name: 'Alice', email: null

        specify 'returns the default if is loading' ->
          @store.current-user.name.$set-loading!
          expect(@store.current-user.$get-or-else @defaultValue).to.eql name: 'Bob', email: 'bob@example.com'

        specify 'returns the default if has error', ->
          @store.current-user.name.$set-error Error 'Failed to get name'
          expect(@store.current-user.$get-or-else @defaultValue).to.eql name: 'Bob', email: 'bob@example.com'


  describe.only '$set' ->

    test-cases 'setting values' [
      -> @tree = build-tree name: __, email: __
      -> @tree = build-tree name: __!, email: __!
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


    test-cases 'setting values on parents of leaves with specified type' [
      -> @tree = build-tree name: __ path: to: leaf: _ initial-value: 123
      -> @store = create-store (_) -> path: to: leaf: _ type: Number
      -> @store = create-store (_) -> path: to: leaf: _ type: \number
    ] ->

      specify 'successfuly sets value if type matches' ->
        @store.$set path: to: leaf: 456
        expect(@store.path.to.leaf.$get!).to.equal 456

      specify 'throws an error if a value is the wrong type' ->
        expect(~>
          @store.$set path: to: leaf: 'Not a number'
        ).to.throw 'Error setting `path.to.leaf`. leaf: "Not a number" (type String) does not match required type Number'


    test-cases 'allow-null isnt false' [
      -> @store = create-store (_) -> path: to: leaf: _
      -> @store = create-store (_) -> path: to: leaf: _!
      -> @store = create-store (_) -> path: to: leaf: _ allow-null: yes
    ] ->
      before-each -> @store.$set path: to: leaf: 'fizz'

      specify 'allows setting null with a deeply nested object to the leaf' ->
        @store.$set path: to: leaf: null
        expect(@store.path.to.leaf.$get!).to.be.null

      specify 'allows setting null on a parent' ->
        @store.$set null
        expect(@store.path.to.leaf.$get!).to.be.null


    describe 'allow-null is false' ->

      before-each ->
        @store = create-store (_) -> path: to: leaf: _ allow-null: no, initial-value: 'fizz'

      specify 'throws an error with a deeply nested object to the leaf' ->
        @store.$set path: to: leaf: 'buzz'
        expect(~> @store.$set path: to: leaf: null).to.throw 'Error setting `path.to.leaf`. leaf: null fails non-null constraint'
        expect(@store.path.to.leaf.$get!).to.equal 'buzz'

      specify 'throws an error setting null on a parent' ->
        @store.$set path: to: leaf: 'buzz'
        expect(~> @store.$set null).to.throw 'Error setting `path.to.leaf`. leaf: null fails non-null constraint'
        expect(@store.path.to.leaf.$get!).to.equal 'buzz'


  describe '$set-error' ->

    test-cases 'setting errors on trees' [
      -> @tree = build-tree name: __, email: __
      -> @tree = build-tree name: __!, email: __!
    ] ->

      specify 'trees initially do not have an error' ->
        expect(@store.current-user.$get-error!).to.be.null

      specify 'sets an error on all leaves' ->
        err = Error 'Error getting name'
        @store.current-user.$set-error err
        expect(@store.current-user.$get-error!).to.equal err
        expect(@store.current-user.name.$get-error!).to.equal err
        expect(@store.current-user.email.$get-error!).to.equal err

      specify 'sets loading to false on all leaves' ->
        @store.current-user.$set-loading!
        @store.current-user.$set-error Error 'Some error'
        expect(@store.current-user.$is-loading!).to.be.false
        expect(@store.current-user.name.$is-loading!).to.be.false
        expect(@store.current-user.email.$is-loading!).to.be.false


  describe '$set-loading' ->

    test-cases 'setting loading on leaves' [
      -> @store = create-store (_) -> path: to: leaf: _
      -> @store = create-store (_) -> path: to: leaf: _!
    ] ->

      specify 'trees are initially not loading' ->
        expect(@store.$is-loading!).to.be.false
        expect(@store.path.$is-loading!).to.be.false
        expect(@store.path.to.$is-loading!).to.be.false

      specify 'called without arguments sets loading on all leaves' ->
        @store.path.$set-loading!
        expect(@store.path.$is-loading!).to.be.true
        expect(@store.path.to.$is-loading!).to.be.true
        expect(@store.path.to.leaf.$is-loading!).to.be.true

      specify 'called with true sets loading on leaves' ->
        @store.path.$set-loading yes
        expect(@store.path.$is-loading!).to.be.true
        expect(@store.path.to.$is-loading!).to.be.true
        expect(@store.path.to.leaf.$is-loading!).to.be.true

      specify 'called with false sets loading to false on all leaves' ->
        @store.path.$set-loading!
        @store.path.$set-loading no
        expect(@store.path.$is-loading!).to.be.false
        expect(@store.path.to.$is-loading!).to.be.false
        expect(@store.path.to.leaf.$is-loading!).to.be.false

      specify 'sets error to null' ->
        @store.path.to.leaf.$set-error Error 'Some error'
        @store.path.$set-loading!
        expect(@store.path.to.leaf.$get-error!).to.be.null


  describe '$reset' ->

    test-cases 'resetting leaves' [
      -> @store = create-store (_) -> path: to: leaf: _
      -> @store = create-store (_) -> path: to: leaf: _!
    ] ->

      specify 'resets data to the initial value' ->
        @store.path.to.leaf.$set 'Alice'
        @store.path.$reset()
        expect(@store.path.to.leaf.$get!).to.be.null

      specify 'sets loading to false on each leaf' ->
        @store.path.to.leaf.$set-loading yes
        @store.path.$reset()
        expect(@store.path.to.leaf.$is-loading!).to.be.false

      specify 'called with false sets loading to false on all leaves' ->
        @store.path.to.leaf.$set-error Error 'Some error'
        @store.path.$reset()
        expect(@store.path.to.leaf.$get-error!).to.be.null


  describe '$from-promise' ->

    before-each ->
      @store = create-store (_) ->
        auth:
          logged-in: _ initial-value: no
          current-user: name: __, email: __
      @promise = @store.auth.current-user.$from-promise new Promise (@resolve, @reject) ~>
      @auth = @store.auth

    specify 'initially sets loading on itself and all sub-nodes' ->
      expect(@auth.logged-in.$is-loading!).to.be.false
      expect(@auth.current-user.$is-loading!).to.be.true
      expect(@auth.current-user.name.$is-loading!).to.be.true
      expect(@auth.current-user.email.$is-loading!).to.be.true

    specify 'it returns a promise' ->
      expect(@promise.then).to.be.a \function

    context 'resolved' ->

      before-each ->
        set-timeout ~> @resolve name: 'Alice', email: 'alice@example.com'
        @promise

      specify 'it removes loading' ->
        expect(@auth.current-user.$is-loading!).to.be.false
        expect(@auth.current-user.name.$is-loading!).to.be.false
        expect(@auth.current-user.email.$is-loading!).to.be.false

      specify 'it sets data' ->
        expect(@auth.current-user.name.$get!).to.equal 'Alice'
        expect(@auth.current-user.email.$get!).to.equal 'alice@example.com'

    context 'resolved with bad type' ->

      before-each ->
        set-timeout ~> @resolve 'some string'
        @promise.catch(@catch-spy = sinon.spy!)

      specify 'it returns a failing promise' ->
        expect(@catch-spy).to.have.been.called-once
        expect(@catch-spy.first-call.args[0]).to.eql Error '$from-promise: called on a tree but promise resolved to a String'

      specify 'it removes loading' ->
        expect(@auth.current-user.$is-loading!).to.be.false
        expect(@auth.current-user.name.$is-loading!).to.be.false
        expect(@auth.current-user.email.$is-loading!).to.be.false

    context 'rejected' ->

      before-each ->
        set-timeout ~> @reject @err = Error 'Failed to get user'
        @promise.catch(@catch-spy = sinon.spy!)

      specify 'it passes the error' ->
        expect(@catch-spy).to.have.been.called-once
        expect(@catch-spy.first-call.args[0]).to.equal @err

      specify 'it removes loading' ->
        expect(@auth.current-user.$is-loading!).to.be.false
        expect(@auth.current-user.name.$is-loading!).to.be.false
        expect(@auth.current-user.email.$is-loading!).to.be.false

      specify 'it sets error' ->
        expect(@auth.current-user.name.$get-error!).to.equal @err
        expect(@auth.current-user.email.$get-error!).to.equal @err


  describe '$on-update' ->

    before-each ->
      @store = create-store (_) ->
        logged-in: _
        current-user:
          name: _ initial-value: 'Alice'
          email: _

      @store.$on-update @store-update-spy = sinon.spy!
      @store.current-user.$on-update @tree-update-spy = sinon.spy!

    specify 'does not call callbacks if nothing updates' ->
      expect(@store-update-spy).to.not.have.been.called
      expect(@tree-update-spy).to.not.have.been.called

    specify 'supports multiple callbacks' ->
      @store.$on-update store-update-spy2 = sinon.spy!
      @store.logged-in.$set yes
      expect(@store-update-spy).to.have.been.called-once
      expect(store-update-spy2).to.have.been.called-once

    specify 'supports removing callbacks' ->
      @store.$off-update @store-update-spy
      @store.logged-in.$set yes
      expect(@store-update-spy).to.not.have.been.called

    test-cases 'triggers when set* methods are called' {
      $set: ->
        @store.current-user.name.$set('Bob')
        @new-values = data: 'Bob', loading: no, error: null
      $set-loading: ->
        @store.current-user.name.$set-loading!
        @new-values = data: null, loading: yes, error: null
      $set-error: ->
        @store.current-user.name.$set-error err = Error 'some error'
        @new-values = data: null, loading: no, error: err
    } ->
      specify 'calls callbacks' ->
        expect(@tree-update-spy).to.have.been.called-once
        expect(@store-update-spy).to.have.been.called-once

      specify 'calls with new-values, old-values, path' ->
        expect(@tree-update-spy).to.have.been.called-with do
          * @new-values
          * data: 'Alice', loading: no, error: null
          * <[currentUser name]>
        expect(@store-update-spy).to.have.been.called-with do
          * @new-values
          * data: 'Alice', loading: no, error: null
          * <[currentUser name]>
