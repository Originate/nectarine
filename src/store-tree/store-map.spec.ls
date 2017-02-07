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


    describe '$get-error' ->

      specify 'returns null by default', ->
        expect(@map.$get-error!).to.be.null

      specify 'returns the error of any child if present', ->
        error = new Error('fail')
        @map.$key('1').$set-error error
        expect(@map.$get-error!).to.eql error


    describe '$get' ->

      specify 'returns an empty object by default' ->
        expect(@map.$get!).to.eql {}

      specify 'returns the children if set', ->
        @map.$key('1').name.$set('Alice')
        expect(@map.$get!).to.eql 1: {name: 'Alice'}


    describe '$is-loading' ->

      specify 'returns false by default', ->
        expect(@map.$is-loading!).to.be.false

      specify 'returns true if a child is loading', ->
        @map.$key('1').$set-loading!
        expect(@map.$is-loading!).to.be.true


    describe '$key', ->

      specify 'creates non existing children false', ->
        expect(@map.$key('1')).to.exist

      specify 'does not overwrite existing children', ->
        @map.$key('1').name.$set('Alice')
        expect(@map.$key('1').name.$get()).to.eql 'Alice'
