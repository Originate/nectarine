require! {
  'react'
  './': Slice
}


describe 'Slice' ->

  specify 'throws if schema and actions have a name clash' ->
    @schema = (_) -> name: _
    @actions = name: -> @slice.name.$get()
    expect(~>
      @result = new Slice {@schema, @actions}
    ).to.throw('Failed to create slice: Action "name" would override schema')

  specify 'binds the actions with {slice} as this', ->
    schema = (_) -> name: _
    actions = initialize: -> @slice.name.$set 'Alice'
    @result = new Slice {schema, actions}
    expect(@result.name.$get()).to.eql null
    initializeFn = @result.initialize
    initializeFn()
    expect(@result.name.$get()).to.eql 'Alice'

  specify 'allows dependency injection for actions', ->
    userService = get: sinon.stub().withArgs(1).returns('Alice')
    schema = (_) -> name: _
    actions = initialize: -> @slice.name.$set @userService.get(1)
    @result = new Slice {schema, actions}
    @result.$inject {userService}
    expect(@result.name.$get()).to.eql null
    initializeFn = @result.initialize
    initializeFn()
    expect(@result.name.$get()).to.eql 'Alice'
