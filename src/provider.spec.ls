require! {
  'react'
  'enzyme': {shallow}
  './provider': Provider
}


class TestComponent extends react.Component


describe 'Provider' ->

  beforeEach ->
    @store = mock: 'slice data'
    @providerHoc = Provider {component: TestComponent, @store}

  specify 'defines a child context type for store', ->
    expect(@providerHoc.child-context-types.store).to.exist

  describe 'rendering', ->
    beforeEach ->
      @wrapper = shallow react.create-element @providerHoc, {}

    specify 'defines a child context with the store', ->
      expect(@wrapper.instance().get-child-context()).to.eql {@store}

    specify 'renders the component', ->
      expect(@wrapper.is('TestComponent')).to.be.true
