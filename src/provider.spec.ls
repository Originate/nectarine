require! {
  'react': {create-element: e}: react
  'enzyme': {shallow}
  './provider': Provider
  './store-tree': StoreTree
}


class TestComponent extends react.Component


describe 'Provider' ->

  beforeEach ->
    @store = new StoreTree {children: {}}

  specify 'defines a child context type for store', ->
    expect(Provider.child-context-types.nectarine-store).to.exist

  specify 'defines a prop type for slice / children', ->
    expect(Provider.prop-types.nectarine-store).to.exist
    expect(Provider.prop-types.children).to.exist

  describe 'rendering', ->
    beforeEach ->
      component = e Provider, {@store}, e(TestComponent)
      @wrapper = shallow component

    specify 'defines a child context with the store', ->
      expect(@wrapper.instance().get-child-context()).to.eql {nectarine-store: @store}

    specify 'renders the component', ->
      expect(@wrapper.is('TestComponent')).to.be.true
