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

  specify 'defines a child context with the slice', ->
    wrapper = shallow react.create-element @providerHoc, {}
    expect(wrapper.instance().get-child-context()).to.eql {@slice}

  specify 'renders the component', ->
    wrapper = shallow react.create-element @providerHoc, {}
    expect(wrapper.is('TestComponent')).to.be.true
