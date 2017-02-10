require! {
  'react'
  './create-slice'
  './create-store'
}


describe 'create-store' ->

  describe 'base', ->
    beforeEach ->
      todos-slice = create-slice do
        schema: (_) -> list: _ initial-value: []
        actions: create: -> @slice.list.$set @slice.list.$get().concat("Say hi to #{@store.user.name.$get()}")
      user-slice = create-slice do
        schema: (_) -> name: _
        actions: initialize: -> @slice.name.$set('Alice')
      @store = create-store do
        todos: todos-slice
        user: user-slice

    specify 'the slices can be accessed', ->
      expect(@store.user.name.$get()).to.eql null
      @store.user.initialize()
      expect(@store.user.name.$get()).to.eql 'Alice'

    specify 'the slices can access each other in actions with store', ->
      @store.user.initialize()
      @store.todos.create()
      expect(@store.todos.list.$get()).to.eql ['Say hi to Alice']

    specify 'the slices have the proper paths', ->
      expect(@store.$get-path-string()).to.eql ''
      expect(@store.user.$get-path-string()).to.eql 'user'
      expect(@store.user.name.$get-path-string()).to.eql 'user.name'

    specify 'the slice listens for changes on its children', ->
      @store.$on-update @store-update-spy = sinon.spy!
      @store.user.initialize()
      expect(@store-update-spy).to.have.been.called

  describe 'action dependency injection', ->
    beforeEach ->
      userService = get: sinon.stub().withArgs(1).returns 'Alice'
      userSlice = create-slice do
        schema: (_) -> name: _
        actions: initialize: -> @slice.name.$set @userService.get(1)
      @store = create-store {user: userSlice}, dependencies: {userService}

    specify 'passes dependencies to slices', ->
      expect(@store.user.name.$get()).to.eql null
      @store.user.initialize()
      expect(@store.user.name.$get()).to.eql 'Alice'

  specify 'a slice can be a leaf', ->
    todos-slice = create-slice do
      schema: (_) -> _ initial-value: []
      actions: initialize: -> @slice.$set @slice.$get().concat('Say hi to Alice')
    store = create-store todos: todos-slice
    expect(store.todos.$get()).to.eql []
    store.todos.initialize()
    expect(store.todos.$get()).to.eql ['Say hi to Alice']

  specify 'a slice can be a map', ->
    todos-slice = create-slice do
      schema: (_, map) -> map text: _
      actions: initialize: -> @slice.$key('1').$set text: 'Say hi to Alice'
    store = create-store todos: todos-slice
    expect(store.todos.$key('1').$get!).to.eql text: null
    store.todos.initialize()
    expect(store.todos.$key('1').$get!).to.eql text: 'Say hi to Alice'

  describe 'schema / action clash', ->
    specify 'throws an error', ->
      userSlice = create-slice do
        schema: (_) -> name: _
        actions: name: (value) -> @slice.name.$set value
      expect(~>
        create-store {user: userSlice}
      ).to.throw '''
        `user`: schema and action keys clash. The following keys would be ambiguous. Update them to be unique
          name
        '''
