require! {
  'react'
  'enzyme': {shallow}
  './connect': connect
  './slice': Slice
}


class TestComponent extends react.Component


schema = (_) -> name: _


describe 'connect' ->

  beforeEach ->
    @connectedHoc = connect do
      component: TestComponent
      map-props: (slice) -> {name: slice.name.$get!}

  specify 'defines a component with a required context type for slice', ->
    expect(@connectedHoc.context-types.slice).to.exist

  describe 'rendering', ->
    before-each ->
      @slice = new Slice {schema}, []
      component = react.create-element @connectedHoc, {other: 'data'}
      @wrapper = shallow component, context: {@slice}

    specify 'renders the component with the passed in props and the result of map-props', ->
      expect(@wrapper.is('TestComponent')).to.be.true
      expect(@wrapper.props()).to.eql {name: null, other: 'data'}

    describe 'when the slice update', ->
      before-each ->
        @slice.name.$set 'Alice'

      specify 're-renders the component with the new result of map-props', ->
        expect(@wrapper.props()).to.eql {name: 'Alice', other: 'data'}
