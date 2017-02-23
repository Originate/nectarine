require! {
  './schema-placeholder': {create-placeholder: __}
  './spec/test-cases'
  './store-leaf': StoreLeaf
  '../utils': {merge-objects}
}


create-leaf = (schema) -> new StoreLeaf {path: <[path to leaf]>, schema}


describe 'StoreLeaf' ->

  describe '$debug' ->
    test-cases '' [
      -> @name = create-leaf __
      -> @name = create-leaf __!
    ] ->

      specify 'with data' ->
        @name.$set 'Alice'
        expect(@name.$debug!).to.be.eql data: 'Alice', loading: false, error: null

      specify 'with loading' ->
        @name.$set-loading!
        expect(@name.$debug!).to.be.eql data: null, loading: true, error: null

      specify 'with error' ->
        @name.$set-error Error 'Some error'
        expect(@name.$debug!).to.be.eql data: null, loading: false, error: Error 'Some error'


  describe '$from-promise' ->

    test-cases 'from promise on leaves' [
      -> @name = create-leaf __
      -> @name = create-leaf __!
    ] ->
      before-each ->
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


  describe '$get-or-else' ->
    test-cases 'setting errors on leaves' [
      -> @name = create-leaf __
      -> @name = create-leaf __!
    ] ->

      describe 'without default' ->
        specify 'returns the data if present' ->
          @name.$set 'Alice'
          expect(@name.$get-or-else!).to.equal 'Alice'

        specify 'returns null if is loading' ->
          @name.$set-loading!
          expect(@name.$get-or-else!).to.be.null

        specify 'returns null if has error', ->
          @name.$set-error Error 'Failed to get name'
          expect(@name.$get-or-else!).to.be.null

      describe 'with default' ->
        specify 'returns the data if present' ->
          @name.$set 'Alice'
          expect(@name.$get-or-else 'Bob').to.equal 'Alice'

        specify 'returns the default if is loading' ->
          @name.$set-loading!
          expect(@name.$get-or-else 'Bob').to.eql 'Bob'

        specify 'returns the default if has error', ->
          @name.$set-error Error 'Failed to get name'
          expect(@name.$get-or-else 'Bob').to.eql 'Bob'


  describe '$on-update' ->

    test-cases [
      -> @leaf = create-leaf __
      -> @leaf = create-leaf __!
    ] ->

      before-each ->
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
            path: <[path to leaf]>
            updates: [{
              old-values: {data: 'foo', loading: no, error: null}
              @new-values
              path: <[path to leaf]>
            }]


  describe '$reset' ->

    test-cases 'without initial-value' [
      -> @name = create-leaf __
      -> @name = create-leaf __!
    ] ->

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
        @name = create-leaf __ initial-value: 'Alice'

      specify 'sets the data to null' ->
        @name.$set 'Bob'
        @name.$reset!
        expect(@name.$get!).to.eql 'Alice'


  describe '$set' ->

    test-cases 'setting values' [
      -> @name = create-leaf __
      -> @name = create-leaf __!
      -> @name = create-leaf __ type: \any
      -> @name = create-leaf __ required: yes, type: \any, initial-value: 'fizz'
    ] ->

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
      -> @leaf = create-leaf __ initial-value: 123
      -> @leaf = create-leaf __ type: Number
      -> @leaf = create-leaf __ type: \number
    ] ->

      specify 'successfuly sets value if type matches' ->
        @leaf.$set 456
        expect(@leaf.$get!).to.equal 456

      specify 'throws an error if a value is the wrong type' ->
        expect(~>
          @leaf.$set 'Not a number'
        ).to.throw 'Error setting `path.to.leaf`: "Not a number" (type String) does not match required type Number'


    test-cases 'required isnt true' [
      -> @leaf = create-leaf __
      -> @leaf = create-leaf __!
      -> @leaf = create-leaf __ required: no
    ] ->

      specify 'allows setting null' ->
        @leaf.$set 'fizz'
        @leaf.$set null
        expect(@leaf.$get!).to.be.null


    describe 'required is true' ->

      before-each ->
        @leaf = create-leaf __ required: yes, initial-value: 'fizz'

      specify 'throws an error' ->
        @leaf.$set 'buzz'
        expect(~> @leaf.$set null).to.throw 'Error setting `path.to.leaf`: null fails non-null constraint'
        expect(@leaf.$get!).to.equal 'buzz'


    test-cases 'leaves with initial value' [
      -> @color = create-leaf __ initial-value: 'red'
      -> @color = create-leaf __ required: yes, initial-value: 'red'
    ] ->

      specify 'leaves are initially set to initial-value' ->
        expect(@color.$get!).to.equal 'red'


    test-cases 'leaves with type object' [
      -> @leaf = create-leaf __ initialValue: {name: 'Alice'}
    ] ->

      specify 'throws if passed the same object', ->
        value = @leaf.$get()
        value.email = 'alice@example.com'
        expect(~>
          @leaf.$set value
        ).to.throw 'Error setting `path.to.leaf`: attempting to update to the same object. Always pass in a new object'

      specify 'works if passed a new object' ->
        @leaf.$set merge-objects(@leaf.$get(), email: 'alice@example.com')
        expect(@leaf.$get()).to.eql name: 'Alice', email: 'alice@example.com'


    test-cases 'leaves with type array' [
      -> @leaf = create-leaf __ initialValue: [1]
    ] ->

      specify 'throws if passed the same object', ->
        value = @leaf.$get()
        value.push 2
        expect(~>
          @leaf.$set value
        ).to.throw 'Error setting `path.to.leaf`: attempting to update to the same object. Always pass in a new object'

      specify 'works if passed a new object' ->
        @leaf.$set @leaf.$get().concat 2
        expect(@leaf.$get()).to.eql [1, 2]


  describe '$set-error' ->

    test-cases 'setting errors on leaves' [
      -> @name = create-leaf __
      -> @name = create-leaf __!
    ] ->

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
        expect(~> @name.$get!).to.throw 'Error getting `path.to.leaf`: has error "Some error"'


  describe '$set-loading' ->

    test-cases 'setting loading on leaves' [
      -> @name = create-leaf __
      -> @name = create-leaf __!
    ] ->

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
        expect(~> @name.$get!).to.throw 'Error getting `path.to.leaf`: is loading'
