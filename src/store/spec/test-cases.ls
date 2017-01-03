require! {
  '..': {create-store}
  './schema-fn-to-string'
}


# Takes in test-cases and generates mocha description
# blocks for each test-case.
module.exports = (description, test-cases, block) ->
  if typeof! description isnt \String
    block = test-cases
    test-cases = description
    description = ''

  switch typeof! test-cases
  | \Array
    for case-fn, case-num in test-cases
      context "#{description} (Case #{case-num})", ->
        before-each case-fn
        block!
  | \Object
    for own case-name, case-fn of test-cases
      context "#{description} (#{case-name})", ->
        before-each case-fn
        block!
  | otherwise => throw Error 'test-cases must be called with array or object'
