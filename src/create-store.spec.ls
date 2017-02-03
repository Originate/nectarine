require! {
  'react'
  './create-slice'
  './create-store'
}


describe 'createStore' ->

  describe 'base', ->
    beforeEach ->
      todos-slice = create-slice do
        schema: (_) -> list: _ initial-value: []
        actions: create: -> @slice.list.$set @slice.list.$get().concat("Say hi to #{@root-slice.user.name.$get()}")
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
      expect(@root-slice.todos.list.$get()).to.eql ['Say hi to Alice']

    specify 'the slices have the proper paths', ->
      expect(@store.$get-path-string()).to.eql ''
      expect(@store.user.$get-path-string()).to.eql 'user'
      expect(@store.user.name.$get-path-string()).to.eql 'user.name'

    specify 'the slice listens for changes on its children', ->
      @store.$on-update @rstore-update-spy = sinon.spy!
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
