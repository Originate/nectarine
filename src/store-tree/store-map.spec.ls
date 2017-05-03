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

      specify 'removes the node from future $getAll calls' ->
        @map.$key('1').$set name: 'Alice'
        @map.$delete('1')
        expect(@map.$get-all!).to.eql {}

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

      specify 'throws an error' ->
        expect(~>
          @map.$get!
        ).to.throw 'Error at `path.to.map`: $get() can not be used on a map. Use $getAll()'


    describe '$get-all' ->

      before-each ->
        @map.$key('1').$set name: 'Alice'
        @map.$key('2').$set-error new Error 'error1'
        @map.$key('3').$set-loading!
        @map.$key('4').$set name: 'Bob'
        @map.$key('5').$set-error new Error 'error2'
        @map.$key('6').$set-loading!

      specify 'returns a mapping of all the keys with data' ->
        expect(@map.$get-all!).to.eql do
          1: {name: 'Alice'}
          4: {name: 'Bob'}


    describe '$get-error' ->

      specify 'throws an error' ->
        expect(~>
          @map.$get-error!
        ).to.throw "Error at `path.to.map`: $getError() can not be used on a map. Use $getAll('error')"


    describe '$is-loading' ->

      specify 'throws an error' ->
        expect(~>
          @map.$is-loading!
        ).to.throw "Error at `path.to.map`: $isLoading() can not be used on a map. Use $getAll('loading')"


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
