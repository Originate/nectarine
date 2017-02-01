require! {
  './': Slice
  './spec/test-cases'
}


create-store = (schema) -> new Slice {schema}


describe 'StoreMap' ->

  describe '$get-error' ->

    test-cases '' [
      -> @store = create-store (_) -> current-user: friendsById: _.map(name: _)
      -> @store = create-store (_) -> current-user: friendsById: _.map(name: _!)
    ] ->

      specify 'returns null by default', ->
        expect(@store.current-user.friendsById.$get-error!).to.be.null

      specify 'returns the error of any child if present', ->
        error = new Error('fail')
        @store.current-user.friendsById.$key('1').$set-error error
        expect(@store.current-user.friendsById.$get-error!).to.eql error


  describe '$get' ->

    test-cases '' [
      -> @store = create-store (_) -> current-user: friendsById: _.map(name: _)
      -> @store = create-store (_) -> current-user: friendsById: _.map(name: _!)
    ] ->

      specify 'returns an empty object by default' ->
        expect(@store.current-user.friendsById.$get!).to.eql {}

      specify 'returns the children if set', ->
        @store.current-user.friendsById.$key('1').name.$set('Alice')
        expect(@store.current-user.friendsById.$get!).to.eql 1: {name: 'Alice'}


  describe '$is-loading' ->

    test-cases '' [
      -> @store = create-store (_) -> current-user: friendsById: _.map(name: _)
      -> @store = create-store (_) -> current-user: friendsById: _.map(name: _!)
    ] ->

      specify 'returns false by default', ->
        expect(@store.current-user.friendsById.$is-loading!).to.be.false

      specify 'returns true if a child is loading', ->
        @store.current-user.friendsById.$key('1').$set-loading!
        expect(@store.current-user.friendsById.$is-loading!).to.be.true


  describe '$key', ->
    test-cases '' [
      -> @store = create-store (_) -> current-user: friendsById: _.map(name: _)
      -> @store = create-store (_) -> current-user: friendsById: _.map(name: _!)
    ] ->

      specify 'creates non existing children false', ->
        expect(@store.current-user.friendsById.$key('1')).to.exist

      specify 'does not overwrite existing children', ->
        @store.current-user.friendsById.$key('1').name.$set('Alice')
        expect(@store.current-user.friendsById.$key('1').name.$get()).to.eql 'Alice'
