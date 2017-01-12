require! {
  'react'
  './slice': Slice
  './create-slice'
}


describe 'createSlice' ->

  beforeEach ->
    @result = createSlice do
      schema: (_) ->
        name: _

      actions:
        initialize: -> @slice.name.$set('Alice')

  specify 'returns a slice', ->
    expect(@result).to.be.instanceOf Slice
