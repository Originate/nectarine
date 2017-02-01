require! {
  'react'
  './slice/store-tree': StoreTree
  './create-slice'
  './combine-slices'
}


describe 'combineSlices' ->

  describe 'base', ->
    beforeEach ->
      todosSlice = createSlice do
        schema: (_) -> list: _ initialValue: []
        actions: create: -> @slice.list.$get().push("Say hi to #{@root-slice.user.name.$get()}")
      userSlice = createSlice do
        schema: (_) -> name: _
        actions: initialize: -> @slice.name.$set('Alice')
      @combinedSlice = combineSlices todos: todosSlice, user: userSlice

    specify 'returns a store tree', ->
      expect(@combinedSlice).to.be.instanceOf StoreTree

    specify 'the slices can be accessed', ->
      expect(@combinedSlice.user.name.$get()).to.eql null
      @combinedSlice.user.initialize()
      expect(@combinedSlice.user.name.$get()).to.eql 'Alice'

    specify 'the slices can access each other in actions with root-slice', ->
      @combinedSlice.user.initialize()
      @combinedSlice.todos.create()
      expect(@combinedSlice.todos.list.$get()).to.eql ['Say hi to Alice']

    specify 'the slices have their paths updated', ->
      expect(@combinedSlice.$get-path-string()).to.eql ''
      expect(@combinedSlice.user.$get-path-string()).to.eql 'user'
      expect(@combinedSlice.user.name.$get-path-string()).to.eql 'user.name'

    specify 'the slice listens for changes on its children', ->
      @combinedSlice.$on-update @combined-slice-update-spy = sinon.spy!
      @combinedSlice.user.initialize()
      expect(@combined-slice-update-spy).to.have.been.called

  describe 'action dependency injection', ->
    beforeEach ->
      userService = get: sinon.stub().withArgs(1).returns 'Alice'
      userSlice = createSlice do
        schema: (_) -> name: _
        actions: initialize: -> @slice.name.$set @userService.get(1)
      @combinedSlice = combineSlices user: userSlice
      @combinedSlice.$inject {userService}

    specify 'passes dependencies to slices', ->
      expect(@combinedSlice.user.name.$get()).to.eql null
      @combinedSlice.user.initialize()
      expect(@combinedSlice.user.name.$get()).to.eql 'Alice'
