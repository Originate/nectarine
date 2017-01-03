require! {
  'chai'
  'sinon'
  'sinon-chai'
}

chai.use sinon-chai

global.expect = chai.expect
global.sinon = sinon
