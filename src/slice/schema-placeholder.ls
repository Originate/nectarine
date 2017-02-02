require! {
  './schema-type': SchemaType
}


class SchemaPlaceholder
  ({@type, @initial-value, @validate, @allow-null} = {}) ->
    if @validate?
      unless @validate.constructor in [Function, RegExp]
        throw new Error "validate must be a function or regular expression (got #{typeof! @validate})"
      if @validate instanceof RegExp and @type isnt SchemaType.STRING
        throw new Error 'validate must be a function if type isnt string'

    if @allow-null is false and not @initial-value?
      throw new Error 'initialValue is required when setting allowNull to false'

    if @initial-value?
      validate this, @initial-value, (err) ->
        "Failed to set initialValue: #{err}"


class NestedSchemaPlaceholder
  (@child-schema) ->
    unless @child-schema
      throw new Error 'child schema not provided to map'


create-leaf-placeholder = (options = {}) ->
  options.type = switch
  | options.type?          => SchemaType.normalize-type options.type
  | options.initial-value? => SchemaType.from-instance options.initial-value
  | otherwise              => SchemaType.ANY

  new SchemaPlaceholder options


create-map-placeholder = (child-map) ->
  new NestedSchemaPlaceholder child-map


is-leaf-placeholder = ->
  it is create-leaf-placeholder or it instanceof SchemaPlaceholder


is-map-placeholder = ->
  it instanceof NestedSchemaPlaceholder


get-type = ->
  | not is-leaf-placeholder it    => throw new Error "#{it} is not a placeholder"
  | it is create-leaf-placeholder => SchemaType.ANY
  | otherwise                     => it.type


validate = (placeholder, value, get-error-string = -> it) ->
  unless value?
    return unless placeholder.allow-null is false
    throw new Error get-error-string "#{String value} fails non-null constraint"

  get-type(placeholder).validate value, get-error-string

  is-valid = switch
  | not placeholder.validate?                => true
  | placeholder.validate instanceof RegExp   => placeholder.validate.test(value)
  | typeof placeholder.validate is \function => placeholder.validate(value)
  unless is-valid
    validate-fn-to-string = switch typeof! placeholder.validate
    | \RegExp   => String(placeholder.validate)
    | \Function => "function #{placeholder.validate.name}"
    throw new Error get-error-string "#{JSON.stringify value} does not validate #{validate-fn-to-string}"


module.exports = {
  create-leaf-placeholder
  create-map-placeholder
  get-type
  is-leaf-placeholder
  is-map-placeholder
  validate
}
