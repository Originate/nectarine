require! {
  'react'
  'enzyme': {shallow}
  './connect': connect
  './create-slice'
  './create-store'
}


class TestComponent extends react.Component


describe 'connect' ->

  specify 'defines a component with a required context type for store', ->
    @connectedHoc = connect component: TestComponent, map-props: ->
    expect(@connectedHoc.context-types.nectarine-store).to.exist

  describe 'rendering', ->
    before-each ->
      users-slice = create-slice schema: (_, map) -> map(name: _)
      @store = create-store users: users-slice
      connectedHoc = connect do
        component: TestComponent
        map-props: (store, ownProps) -> {name: store.users.$key(ownProps.id).name.$get!}
      component = react.create-element connectedHoc, {id: '1'}
      @wrapper = shallow component, context: {nectarine-store: @store}

    specify 'renders the component with the passed in props and the result of map-props', ->
      expect(@wrapper.is('TestComponent')).to.be.true
      expect(@wrapper.props()).to.eql {id: '1', name: null}

    describe 'when the store update', ->
      before-each ->
        @store.users.$key('1').name.$set 'Alice'

      specify 're-renders the component with the new result of map-props', ->
        expect(@wrapper.props()).to.eql {id: '1', name: 'Alice'}
