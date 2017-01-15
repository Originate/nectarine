require! {
  'react'
  './': Slice
}


describe 'Slice' ->

  describe 'schema and actions have a name clash' ->
    beforeEach ->
      @schema = (_) -> name: _
      @actions = name: -> @slice.name.$get()

    describe 'root path' ->
      specify 'throws' ->
        expect(~>
          @result = new Slice {@schema, @actions}, []
        ).to.throw('Failed to create slice "[root]": Action "name" would override schema')

    describe 'non-root path' ->
      specify 'throws' ->
        expect(~>
          @result = new Slice {@schema, @actions}, ['some', 'path']
        ).to.throw('Failed to create slice "some.path": Action "name" would override schema')

  specify 'binds the actions with {slice} as this', ->
    schema = (_) -> name: _
    actions = initialize: -> @slice.name.$set 'Alice'
    @result = new Slice {schema, actions}, []
    expect(@result.name.$get()).to.eql null
    initializeFn = @result.initialize
    initializeFn()
    expect(@result.name.$get()).to.eql 'Alice'

  specify 'allows dependency injection for actions', ->
    userService = get: sinon.stub().withArgs(1).returns('Alice')
    schema = (_) -> name: _
    actions = initialize: -> @slice.name.$set @userService.get(1)
    @result = new Slice {schema, actions}, []
    @result.$inject {userService}
    expect(@result.name.$get()).to.eql null
    initializeFn = @result.initialize
    initializeFn()
    expect(@result.name.$get()).to.eql 'Alice'
