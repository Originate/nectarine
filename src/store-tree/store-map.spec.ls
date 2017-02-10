require! {
  './schema-placeholder': {create-placeholder: __}
  './store-map': StoreMap
  './spec/test-cases'
}


create-map = (child-schema) -> new StoreMap {child-schema, path: <[path to map]>}


describe 'StoreMap' ->

  test-cases '' [
    -> @map = create-map name: __
    -> @map = create-map name: __!
  ] ->


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

      describe 'with data' ->

        specify 'returns a mapping of all the keys with data' ->
          expect(@map.$get-all!).to.eql do
            1: {name: 'Alice'}
            4: {name: 'Bob'}

      describe 'with errors' ->

        specify 'returns a mapping of all the keys with errors' ->
          expect(@map.$get-all('error')).to.eql do
            2: new Error 'error1'
            5: new Error 'error2'

      describe 'are loading' ->

        specify 'returns an array of all the keys that are loading' ->
          expect(@map.$get-all('loading')).to.eql do
            3: true
            6: true


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
