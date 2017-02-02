require! {
  'react'
  './slice': Slice
  './create-slice'
}


describe 'createSlice' ->

  describe 'single level', ->

    specify 'throws if schema is not an object or function a slice', ->
      expect ->
        @result = createSlice {}
      .to.throw '"schema" must be a function or object'

    specify 'returns a slice', ->
      @result = createSlice do
        schema: (_) -> name: _
        actions: initialize: -> @slice.name.$set('Alice')
      expect(@result).to.be.instanceOf Slice


  describe 'nested slices', ->

    describe 'base', ->
      beforeEach ->
        todosSlice = createSlice do
          schema: (_) -> list: _ initialValue: []
          actions: create: -> @slice.list.$set @slice.list.$get().concat("Say hi to #{@root-slice.user.name.$get()}")
        userSlice = createSlice do
          schema: (_) -> name: _
          actions: initialize: -> @slice.name.$set('Alice')
        @root-slice = createSlice do
          schema: {todos: todosSlice, user: userSlice}

      specify 'the slices can be accessed', ->
        expect(@root-slice.user.name.$get()).to.eql null
        @root-slice.user.initialize()
        expect(@root-slice.user.name.$get()).to.eql 'Alice'

      specify 'the slices can access each other in actions with root-slice', ->
        @root-slice.user.initialize()
        @root-slice.todos.create()
        expect(@root-slice.todos.list.$get()).to.eql ['Say hi to Alice']

      specify 'the slices have their paths updated', ->
        expect(@root-slice.$get-path-string()).to.eql ''
        expect(@root-slice.user.$get-path-string()).to.eql 'user'
        expect(@root-slice.user.name.$get-path-string()).to.eql 'user.name'

      specify 'the slice listens for changes on its children', ->
        @root-slice.$on-update @root-slice-update-spy = sinon.spy!
        @root-slice.user.initialize()
        expect(@root-slice-update-spy).to.have.been.called

    describe 'action dependency injection', ->
      beforeEach ->
        userService = get: sinon.stub().withArgs(1).returns 'Alice'
        userSlice = createSlice do
          schema: (_) -> name: _
          actions: initialize: -> @slice.name.$set @userService.get(1)
        @root-slice = createSlice do
          schema: {user: userSlice}
          dependencies: {userService}

      specify 'passes dependencies to slices', ->
        expect(@root-slice.user.name.$get()).to.eql null
        @root-slice.user.initialize()
        expect(@root-slice.user.name.$get()).to.eql 'Alice'
