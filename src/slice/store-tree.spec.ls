require! {
  './': Slice
  './spec/test-cases'
}


create-store = (schema) -> new Slice {schema}, []


describe 'StoreTree' ->

  describe '$get' ->

    test-cases '' [
      -> @store = create-store (_) -> current-user: name: _, email: _
      -> @store = create-store (_) -> current-user: name: _!, email: _!
    ] ->

      specify 'throws an error when attempting to access data with error' ->
        @store.current-user.name.$set 'Alice'
        @store.current-user.email.$set-error Error 'Failed to get email'
        expect(~> @store.current-user.$get!).to.throw 'Error getting `currentUser.email`. email: has error "Failed to get email"'

      specify 'throws an error when attempting to access loading data' ->
        @store.current-user.name.$set 'Alice'
        @store.current-user.email.$set-loading!
        expect(~> @store.current-user.$get!).to.throw 'Error getting `currentUser.email`. email: is loading'


  describe '$get-or-else' ->
    test-cases '' [
      -> @store = create-store (_) -> current-user: name: _, email: _
      -> @store = create-store (_) -> current-user: name: _!, email: _!
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


  describe '$set' ->

    test-cases 'setting values' [
      -> @store = create-store (_) -> current-user: name: _, email: _
      -> @store = create-store (_) -> current-user: name: _!, email: _!
    ] ->
      before-each -> @current-user = @store.current-user

      specify 'sets the values on the tree' ->
        @current-user.$set name: 'Alice', email: 'alice@example.com'
        expect(@current-user.$get!).to.eql name: 'Alice', email: 'alice@example.com'

      specify 'sets loading to false for all leaves' ->
        @current-user.name.$set-loading!
        @current-user.email.$set-loading!
        @current-user.$set name: 'Alice', email: 'alice@example.com'
        expect(@current-user.$is-loading!).to.be.false
        expect(@current-user.name.$is-loading!).to.be.false
        expect(@current-user.email.$is-loading!).to.be.false

      specify 'sets error to null' ->
        @current-user.name.$set-error Error 'Failed to get name'
        @current-user.email.$set-error Error 'Failed to get email'
        @current-user.$set name: 'Alice', email: 'alice@example.com'
        expect(@current-user.$get-error!).to.be.null
        expect(@current-user.name.$get-error!).to.be.null
        expect(@current-user.email.$get-error!).to.be.null

      specify 'ignores extra keys' ->
        @current-user.$set name: 'Alice', foo: 'bar'
        expect(@current-user.$get!).to.eql name: 'Alice', email: null

      specify 'setting a non-object on a parent throws an error' ->
        expect(~> @current-user.$set 'Alice').to.throw 'calling $set on a tree must be called with an object'

      specify 'batches updates until all have been performed', ->
        values = []
        update-spy = sinon.spy ~> values.push @current-user.$get()
        @current-user.$on-update update-spy
        @current-user.$set name: 'Alice', email: 'alice@example.com'
        expect(values).to.eql [
          {name: 'Alice', email: 'alice@example.com'},
          {name: 'Alice', email: 'alice@example.com'}
        ]
        expect(update-spy.args[0][3].batch-id).to.eql update-spy.args[1][3].batch-id
        expect(update-spy.args[0][3].batch-path).to.eql <[currentUser]>
        expect(update-spy.args[1][3].batch-path).to.eql <[currentUser]>


    test-cases 'setting values on parents of leaves with specified type' [
      -> @store = create-store (_) -> path: to: leaf: _ initial-value: 123
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
      -> @store = create-store (_) -> current-user: name: _, email: _
      -> @store = create-store (_) -> current-user: name: _!, email: _!
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

      specify 'batches updates until all have been performed', ->
        err = new Error 'Some error'
        values = []
        update-spy = sinon.spy ~> values.push @store.current-user.email.$get-error()
        @store.current-user.$on-update update-spy
        @store.current-user.$set-error err
        expect(values).to.eql [err, err]
        expect(update-spy.args[0][3].batch-id).to.eql update-spy.args[1][3].batch-id
        expect(update-spy.args[0][3].batch-path).to.eql <[currentUser]>
        expect(update-spy.args[1][3].batch-path).to.eql <[currentUser]>


  describe '$set-loading' ->

    test-cases 'setting loading on leaves' [
      -> @store = create-store (_) -> path: to: leaf: _, leaf2: _
      -> @store = create-store (_) -> path: to: leaf: _!, leaf2: _!
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

      specify 'batches updates until all have been performed', ->
        values = []
        update-spy = sinon.spy ~> values.push @store.path.to.leaf2.$is-loading!
        @store.path.$on-update update-spy
        @store.path.$set-loading!
        expect(values).to.eql [true, true]
        expect(update-spy.args[0][3].batch-id).to.eql update-spy.args[1][3].batch-id
        expect(update-spy.args[0][3].batch-path).to.eql <[path]>
        expect(update-spy.args[1][3].batch-path).to.eql <[path]>


  describe '$reset' ->

    test-cases 'resetting leaves' [
      -> @store = create-store (_) -> path: to: leaf: _, leaf2: _
      -> @store = create-store (_) -> path: to: leaf: _!, leaf2: _!
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

      specify 'batches updates until all have been performed', ->
        values = []
        update-spy = sinon.spy ~> values.push @store.path.to.leaf2.$get!
        @store.path.to.leaf2.$set 'Bob'
        @store.path.$on-update update-spy
        @store.path.$reset()
        expect(values).to.eql [null, null]
        expect(update-spy.args[0][3].batch-id).to.eql update-spy.args[1][3].batch-id
        expect(update-spy.args[0][3].batch-path).to.eql <[path]>
        expect(update-spy.args[1][3].batch-path).to.eql <[path]>


  describe '$from-promise' ->

    before-each ->
      @store = create-store (_) ->
        auth:
          logged-in: _ initial-value: no
          current-user: name: _, email: _
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
      @store.current-user.$on-update @current-user-update-spy = sinon.spy!

    specify 'does not call callbacks if nothing updates' ->
      expect(@store-update-spy).to.not.have.been.called
      expect(@current-user-update-spy).to.not.have.been.called

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
        expect(@current-user-update-spy).to.have.been.called-once
        expect(@store-update-spy).to.have.been.called-once

      specify 'calls with new-values, old-values, path' ->
        expect(@current-user-update-spy).to.have.been.called-with do
          * @new-values
          * data: 'Alice', loading: no, error: null
          * <[currentUser name]>
        expect(@store-update-spy).to.have.been.called-with do
          * @new-values
          * data: 'Alice', loading: no, error: null
          * <[currentUser name]>
