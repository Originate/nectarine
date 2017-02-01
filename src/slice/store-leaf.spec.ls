require! {
  './': Slice
  './spec/test-cases'
}


create-store = (schema) -> new Slice {schema}, []


describe 'StoreLeaf' ->

  describe '$set' ->

    test-cases 'setting values' [
      -> @store = create-store (_) -> name: _, email: _
      -> @store = create-store (_) -> name: _!, email: _!
      -> @store = create-store (_) -> name: _(type: \any), email: _(type: \any)
      -> @store = create-store (_) -> name: _ allow-null: no, type: \any, initial-value: 'fizz'
    ] ->
      before-each -> @name = @store.name

      specify 'sets the value of the leaf' ->
        @name.$set 'Alice'
        expect(@name.$get!).to.equal 'Alice'
        @name.$set 123
        expect(@name.$get!).to.equal 123

      specify 'sets loading to false' ->
        @name.$set-loading!
        @name.$set 'Alice'
        expect(@name.$is-loading!).to.be.false

      specify 'sets error to null' ->
        @name.$set-error Error 'Failed to get name'
        @name.$set 'Alice'
        expect(@name.$get-error!).to.be.null


    test-cases 'setting values on leaves with specified type' [
      -> @store = create-store (_) -> path: to: leaf: _ initial-value: 123
      -> @store = create-store (_) -> path: to: leaf: _ type: Number
      -> @store = create-store (_) -> path: to: leaf: _ type: \number
    ] ->
      before-each -> @leaf = @store.path.to.leaf

      specify 'successfuly sets value if type matches' ->
        @leaf.$set 456
        expect(@leaf.$get!).to.equal 456

      specify 'throws an error if a value is the wrong type' ->
        expect(~>
          @leaf.$set 'Not a number'
        ).to.throw 'Error setting `path.to.leaf`. leaf: "Not a number" (type String) does not match required type Number'


    test-cases 'allow-null isnt false' [
      -> @store = create-store (_) -> path: to: leaf: _
      -> @store = create-store (_) -> path: to: leaf: _!
      -> @store = create-store (_) -> path: to: leaf: _ allow-null: yes
    ] ->
      before-each -> @leaf = @store.path.to.leaf

      specify 'allows setting null' ->
        @leaf.$set 'fizz'
        @leaf.$set null
        expect(@leaf.$get!).to.be.null


    describe 'allow-null is false' ->

      before-each ->
        @store = create-store (_) -> path: to: leaf: _ allow-null: no, initial-value: 'fizz'
        @leaf = @store.path.to.leaf

      specify 'throws an error' ->
        @leaf.$set 'buzz'
        expect(~> @leaf.$set null).to.throw 'Error setting `path.to.leaf`. leaf: null fails non-null constraint'
        expect(@leaf.$get!).to.equal 'buzz'


    test-cases 'leaves with initial value' [
      -> @store = create-store (_) -> color: _ initial-value: 'red'
      -> @store = create-store (_) -> color: _ allow-null: no, initial-value: 'red'
    ] ->
      before-each -> @color = @store.color

      specify 'leaves are initially set to initial-value' ->
        expect(@color.$get!).to.equal 'red'


  describe '$set-error' ->

    test-cases 'setting errors on leaves' [
      -> @store = create-store (_) -> current-user: name: _
      -> @store = create-store (_) -> current-user: name: _!
    ] ->
      before-each -> @name = @store.current-user.name

      specify 'leaves initially do not have an error' ->
        expect(@name.$get-error!).to.be.null

      specify 'sets an error' ->
        err = Error 'Error getting name'
        @name.$set-error err
        expect(@name.$get-error!).to.equal err

      specify 'sets loading to false' ->
        @name.$set-loading!
        @name.$set-error Error 'Some error'
        expect(@name.$is-loading!).to.be.false

      specify 'throws an error when attempting to access data' ->
        @name.$set 'Alice'
        @name.$set-error Error 'Some error'
        expect(~> @name.$get!).to.throw 'Error getting `currentUser.name`. name: has error "Some error"'


  describe '$set-loading' ->

    test-cases 'setting loading on leaves' [
      -> @store = create-store (_) -> current-user: name: _
      -> @store = create-store (_) -> current-user: name: _!
    ] ->
      before-each -> @name = @store.current-user.name

      specify 'leaves are initially not loading' ->
        expect(@name.$is-loading!).to.be.false

      specify 'called without arguments sets loading' ->
        @name.$set-loading!
        expect(@name.$is-loading!).to.be.true

      specify 'called with true sets loading' ->
        @name.$set-loading yes
        expect(@name.$is-loading!).to.be.true

      specify 'called with false sets loading to false' ->
        @name.$set-loading!
        @name.$set-loading no
        expect(@name.$is-loading!).to.be.false

      specify 'sets error to null' ->
        @name.$set-error Error 'Some error'
        @name.$set-loading!
        expect(@name.$get-error!).to.be.null

      specify 'throws an error when attempting to access data' ->
        @name.$set 'Alice'
        @name.$set-loading!
        expect(~> @name.$get!).to.throw 'Error getting `currentUser.name`. name: is loading'


  describe '$reset' ->

    test-cases 'without initial-value' [
      -> @store = create-store (_) -> current-user: name: _
      -> @store = create-store (_) -> current-user: name: _!
    ] ->
      before-each ->
        @name = @store.current-user.name

      specify 'sets the data to null' ->
        @name.$set 'Alice'
        @name.$reset!
        expect(@name.$get!).to.be.null

      specify 'sets loading to false' ->
        @name.$set-error Error 'Some error'
        @name.$reset!
        expect(@name.$is-loading!).to.be.false

      specify 'sets error to null' ->
        @name.$set-error Error 'Some error'
        @name.$reset!
        expect(@name.$get-error!).to.be.null

    describe 'with initial-value' ->
      before-each ->
        @store = create-store (_) -> current-user: name: _ initial-value: 'Alice'
        @name = @store.current-user.name

      specify 'sets the data to null' ->
        @name.$set 'Bob'
        @name.$reset!
        expect(@name.$get!).to.eql 'Alice'


  describe '$from-promise' ->

    test-cases 'from promise on leaves' [
      -> @store = create-store (_) -> current-user: name: _
      -> @store = create-store (_) -> current-user: name: _!
    ] ->
      before-each ->
        @name = @store.current-user.name
        @promise = @name.$from-promise new Promise (@resolve, @reject) ~>
        null

      specify 'initially sets loading' ->
        expect(@name.$is-loading!).to.be.true

      specify 'it returns a promise' ->
        expect(@promise.then).to.be.a \function

      context 'resolved' ->

        before-each ->
          set-timeout ~> @resolve 'Alice'
          @promise

        specify 'it removes loading' ->
          expect(@name.$is-loading!).to.be.false

        specify 'it sets data' ->
          expect(@name.$get!).to.equal 'Alice'

      context 'rejected' ->

        before-each ->
          set-timeout ~> @reject @err = Error 'Failed to get name'
          @promise.catch(@catch-spy = sinon.spy!)

        specify 'it passes the error' ->
          expect(@catch-spy).to.have.been.called-once
          expect(@catch-spy.first-call.args[0]).to.equal @err

        specify 'it removes loading' ->
          expect(@name.$is-loading!).to.be.false

        specify 'it sets error' ->
          expect(@name.$get-error!).to.equal @err


  describe '$on-update' ->

    test-cases [
      -> @store = create-store (_) -> path: to: leaf: _
      -> @store = create-store (_) -> path: to: leaf: _!
    ] ->

      before-each ->
        @leaf = @store.path.to.leaf
        @leaf.$set 'foo'
        @leaf.$on-update @update-spy = sinon.spy!

      specify 'does not call callbacks if nothing updates' ->
        expect(@update-spy).to.not.have.been.called

      specify 'supports multiple callbacks' ->
        @leaf.$on-update update-spy2 = sinon.spy!
        @leaf.$set 'bar'
        expect(@update-spy).to.have.been.called-once
        expect(update-spy2).to.have.been.called-once

      specify 'supports removing callbacks' ->
        @leaf.$off-update @update-spy
        @leaf.$set 'bar'
        expect(@update-spy).to.not.have.been.called-once

      test-cases 'triggers when set* methods are called' {
        $set: ->
          @leaf.$set('bar')
          @new-values = data: 'bar', loading: no, error: null
        $set-loading: ->
          @leaf.$set-loading!
          @new-values = data: null, loading: yes, error: null
        $set-error: ->
          @leaf.$set-error err = Error 'some error'
          @new-values = data: null, loading: no, error: err
      } ->
        specify 'calls callbacks' ->
          expect(@update-spy).to.have.been.called-once

        specify 'calls with new-values, old-values, path' ->
          expect(@update-spy).to.have.been.called-with do
            * @new-values
            * data: 'foo', loading: no, error: null
            * <[path to leaf]>
