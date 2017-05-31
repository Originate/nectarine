require! {
  './schema-placeholder': {create-placeholder: __}
  './store-map': StoreMap
  './spec/test-cases'
}


create-map = (child-schema) -> new StoreMap {child-schema, path: <[path to map]>}


describe 'StoreMap' ->

  test-cases '' [
    -> @map = create-map name: __!
  ] ->


    specify 'sets the path for children correctly' ->
      expect(@map.$key('1').name.$get-path!).to.eql <[path to map 1 name]>


    describe '$delete' ->

      specify 'removes an data' ->
        @map.$key('1').$set name: 'Alice'
        @map.$delete('1')
        expect(@map.$key('1').$get!).to.eql name: null

      specify 'removes the node from future $get calls' ->
        @map.$key('1').$set name: 'Alice'
        @map.$delete('1')
        expect(@map.$get!).to.eql {}

      specify 'removes the key from future $keys calls' ->
        @map.$key('1').$set name: 'Alice'
        @map.$delete('1')
        expect(@map.$keys!).to.eql []


    describe '$debug' ->

      specify 'returns an empty object if no keys have been accessed' ->
        expect(@map.$debug!).to.eql {}

      specify 'returns the debugged objects of the accessed keys' ->
        @map.$key('1').$set name: 'Alice'
        expect(@map.$debug!).to.eql 1: name: {data: 'Alice', loading: false, error: null}


    describe '$from-promise' ->

      specify 'throws an error' ->
        expect(~>
          promise = new Promise (resolve) -> resolve name: 'Alice'
          @map.$from-promise(promise)
        ).to.throw "Error at `path.to.map`: $fromPromise() can not be used on a map. Use $key(k).$fromPromise(v)"


    describe '$get' ->

      specify 'returns a mapping of all the keys' ->
        @map.$key('1').$set name: 'Alice'
        @map.$key('2').$set name: 'Bob'
        expect(@map.$get!).to.eql do
          1: {name: 'Alice'}
          2: {name: 'Bob'}

      specify 'throws an error when attempting to access data with error' ->
        @map.$key('1').$set name: 'Alice'
        @map.$key('2').$set-error new Error 'error1'
        expect(~> @map.$get!).to.throw 'Error getting `path.to.map.2.name`: has error "error1"'

      specify 'throws an error when attempting to access loading data' ->
        @map.$key('1').$set name: 'Alice'
        @map.$key('2').$set-loading!
        expect(~> @map.$get!).to.throw 'Error getting `path.to.map.2.name`: is loading'


    describe '$get-error' ->

      specify 'returns null for an empty map' ->
        expect(@map.$get-error!).to.eql null

      specify 'returns null if all keys have data' ->
        @map.$key('1').$set name: 'Alice'
        @map.$key('2').$set name: 'Bob'
        expect(@map.$get!).to.eql do
          1: {name: 'Alice'}
          2: {name: 'Bob'}

      specify 'returns the first error if any keys have errors' ->
        @map.$key('1').$set name: 'Alice'
        @map.$key('2').$set-error new Error 'error1'
        expect(@map.$get-error!).to.eql new Error 'error1'

      specify 'returns the first error if multiple keys have errors' ->
        @map.$key('1').$set-error new Error 'error1'
        @map.$key('2').$set-error new Error 'error2'
        expect(@map.$get-error!).to.eql new Error 'error2'

    describe '$is-loading' ->

      specify 'returns false for an empty map' ->
        expect(@map.$is-loading!).to.eql false

      specify 'returns false if all keys have data' ->
        @map.$key('1').$set name: 'Alice'
        @map.$key('2').$set name: 'Bob'
        expect(@map.$is-loading!).to.eql false

      specify 'returns true if any keys have errors' ->
        @map.$key('1').$set name: 'Alice'
        @map.$key('2').$set-loading!
        expect(@map.$is-loading!).to.eql true

    describe '$key', ->

      specify 'creates non existing children false', ->
        expect(@map.$key('1')).to.exist

      specify 'does not overwrite existing children', ->
        @map.$key('1').name.$set('Alice')
        expect(@map.$key('1').name.$get()).to.eql 'Alice'


    describe '$keys' ->

      specify 'returns an empty array by default' ->
        expect(@map.$keys!).to.eql []

      specify 'returns the keys of the initialized objects' ->
        @map.$key('1').$set name: 'Alice'
        @map.$key('2').$set-error new Error 'error1'
        @map.$key('3').$set-loading!
        expect(@map.$keys!).to.eql ['1', '2', '3']


    describe '$set' ->

      specify 'throws an error' ->
        expect(~>
          @map.$set(1: {name: 'Alice'})
        ).to.throw "Error at `path.to.map`: $set() can not be used on a map. Use $key(k).$set(v)"


    describe '$set-error' ->

      specify 'throws an error' ->
        expect(~>
          @map.$set-error(new Error('my error'))
        ).to.throw "Error at `path.to.map`: $setError() can not be used on a map. Use $key(k).$setError(e)"


    describe '$set-loading' ->

      specify 'throws an error' ->
        expect(~>
          @map.$set-loading!
        ).to.throw "Error at `path.to.map`: $setLoading() can not be used on a map. Use $key(k).$setLoading()"
