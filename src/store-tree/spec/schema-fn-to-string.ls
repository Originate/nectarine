# Takes a schema funciton and turns it into a string.
# Used to create human-readable output for specs
#
# e.g.
#   (_) -> name: _ type: String
# returns
#   "name: _( type: String )"
module.exports = (schema-fn) ->
  schema-fn
    .to-string!
    .replace /\s*\n\s*/g, ' '
    .replace /function.+return (.+);/, \$1
    .replace /[{}]/g, ''
    .replace /\s+/g, ' '
