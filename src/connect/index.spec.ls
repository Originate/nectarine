require! {
  'react'
  'enzyme': {shallow}
  './': connect
  '../create-slice'
  '../create-store'
}


class TestComponent extends react.Component


describe 'connect' ->

  describe 'map props', ->
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

  describe 'bind props', ->
    specify 'defines a component with a required context type for store', ->
      @connectedHoc = connect component: TestComponent, map-props: ->
      expect(@connectedHoc.context-types.nectarine-store).to.exist

    describe 'rendering', ->
      before-each ->
        users-slice = create-slice schema: (_, map) -> map(name: _)
        @store = create-store users: users-slice
        connectedHoc = connect do
          component: TestComponent
          bind-props: (store, ownProps) ->
            name: store.users.$key(ownProps.id).name
            setName: (value) -> store.users.$key(ownProps.id).name.$set value
        component = react.create-element connectedHoc, {id: '1'}
        @wrapper = shallow component, context: {nectarine-store: @store}

      specify 'renders the passed component', ->
        expect(@wrapper.is('TestComponent')).to.be.true

      specify 'adds results of the bound store nodes', ->
        expect(@wrapper.props().name).to.be.null
        expect(@wrapper.props().isLoading).to.be.false
        expect(@wrapper.props().errors).to.eql []

      specify 'passes through own props', ->
        expect(@wrapper.props().id).to.eql '1'

      specify 'passes through non store nodes from bind-props', ->
        expect(@wrapper.props().setName).to.be.instanceof Function

      describe 'when the store node updates with data', ->
        before-each ->
          @store.users.$key('1').name.$set 'Alice'

        specify 're-renders the component with the updated props', ->
          expect(@wrapper.props().name).to.eql 'Alice'
          expect(@wrapper.props().isLoading).to.be.false
          expect(@wrapper.props().errors).to.eql []

      describe 'when the store node updates with error', ->
        before-each ->
          @store.users.$key('1').name.$setLoading()

        specify 're-renders the component with the updated props', ->
          expect(@wrapper.props().name).to.be.null
          expect(@wrapper.props().isLoading).to.be.true
          expect(@wrapper.props().errors).to.eql []

      describe 'when the store node updates with loading', ->
        before-each ->
          @error = new Error 'api error'
          @store.users.$key('1').name.$setError @error

        specify 're-renders the component with the updated props', ->
          expect(@wrapper.props().name).to.be.null
          expect(@wrapper.props().isLoading).to.be.false
          expect(@wrapper.props().errors).to.eql [@error]

      describe 'when the component receives new props', ->
        before-each ->
          @wrapper.setProps {id: '2'}
          @store.users.$key('2').name.$set 'Bob'

        specify 'recomputes bind-props', ->
          expect(@wrapper.props().id).to.eql '2'
          expect(@wrapper.props().name).to.eql 'Bob'
          expect(@wrapper.props().isLoading).to.be.false
          expect(@wrapper.props().errors).to.eql []
