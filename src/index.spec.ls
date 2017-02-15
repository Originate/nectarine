require! {
  './index': nectarine
}


describe 'index' ->

  specify 'exports all the tope level api', ->
    expect(Object.keys(nectarine)).to.eql <[connect createLogger createSlice createStore Provider]>
