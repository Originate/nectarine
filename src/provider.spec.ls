require! {
  'react': {create-element: e}: react
  'enzyme': {shallow}
  './provider': Provider
  './slice': Slice
}


class TestComponent extends react.Component


describe 'Provider' ->

  beforeEach ->
    @slice = new Slice {}

  specify 'defines a child context type for slice', ->
    expect(Provider.child-context-types.slice).to.exist

  specify 'defines a prop type for slice / children', ->
    expect(Provider.prop-types.slice).to.exist
    expect(Provider.prop-types.children).to.exist

  describe 'rendering', ->
    beforeEach ->
      component = e Provider, {@slice}, e(TestComponent)
      @wrapper = shallow component

    specify 'defines a child context with the slice', ->
      expect(@wrapper.instance().get-child-context()).to.eql {@slice}

    specify 'renders the component', ->
      expect(@wrapper.is('TestComponent')).to.be.true
