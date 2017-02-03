require! {
  'react'
  'enzyme': {shallow}
  './connect': connect
  './create-slice'
  './create-store'
}


class TestComponent extends react.Component


schema = (_) -> name: _


describe 'connect' ->

  beforeEach ->
    @connectedHoc = connect do
      component: TestComponent
      map-props: (store) -> {name: store.user.name.$get!}

  specify 'defines a component with a required context type for store', ->
    expect(@connectedHoc.context-types.store).to.exist

  describe 'rendering', ->
    before-each ->
      user-slice = create-slice schema: (_) -> name: _
      @store = create-store user: user-slice
      component = react.create-element @connectedHoc, {other: 'data'}
      @wrapper = shallow component, context: {@store}

    specify 'renders the component with the passed in props and the result of map-props', ->
      expect(@wrapper.is('TestComponent')).to.be.true
      expect(@wrapper.props()).to.eql {name: null, other: 'data'}

    describe 'when the store update', ->
      before-each ->
        @store.user.name.$set 'Alice'

      specify 're-renders the component with the new result of map-props', ->
        expect(@wrapper.props()).to.eql {name: 'Alice', other: 'data'}
