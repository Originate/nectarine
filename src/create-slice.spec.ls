require! {
  './create-slice'
}


describe 'create-slice' ->

  specify 'throws if schema is not an object', ->
    expect ->
      create-slice schema: []
    .to.throw '"schema" must be an object or a function that returns an object'

  specify 'throws if schema is a function that does not return an object', ->
    expect ->
      create-slice schema: -> []
    .to.throw '"schema" must be an object or a function that returns an object'
