require! {
  'react'
  'enzyme': {shallow}
  './provider': Provider
}


class TestComponent extends react.Component


describe 'Provider' ->

  beforeEach ->
    @slice = mock: 'slice data'
    @providerHoc = Provider(TestComponent, @slice)

  specify 'defines a child context type for slice', ->
    expect(@providerHoc.child-context-types.slice).to.exist

  describe 'rendering', ->
    beforeEach ->
      @wrapper = shallow react.create-element @providerHoc, {}

    specify 'defines a child context with the slice', ->
      expect(@wrapper.instance().get-child-context()).to.eql {@slice}

    specify 'renders the component', ->
      expect(@wrapper.is('TestComponent')).to.be.true
