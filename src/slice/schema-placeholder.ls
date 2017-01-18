require! {
  './schema-type': SchemaType
}


class SchemaPlaceholder
  (options = {}) ->
    {@type, @initial-value, @validate, @allow-null, @element-type, @shape, @value-type} = options
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


create-placeholder = (options = {}) ->
  options.type = switch
  | options.type?          => SchemaType.normalize-type options.type
  | options.initial-value? => SchemaType.from-instance options.initial-value
  | otherwise              => SchemaType.ANY

  for key in ['elementType'] when options[key]
    options[key] = new SchemaPlaceholder options[key]

  if options.shape
    for key, value of options.shape
      options.shape[key] = new SchemaPlaceholder value

  new SchemaPlaceholder options


is-placeholder = ->
  it is create-placeholder or it instanceof SchemaPlaceholder


get-type = ->
  | not is-placeholder it    => throw new Error "#{it} is not a placeholder"
  | it is create-placeholder => SchemaType.ANY
  | otherwise                => it.type


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

  if get-type(placeholder) is SchemaType.ARRAY and placeholder.element-type
    for element, index in value
      validate placeholder.element-type, element, (err) -> get-error-string "[#{index}]: #{err}"

  if get-type(placeholder) is SchemaType.OBJECT and placeholder.shape
    for key, valueType of placeholder.shape
      validate valueType, value[key], (err) -> get-error-string "[#{key}]: #{err}"

  if get-type(placeholder) is SchemaType.OBJECT and placeholder.value-type
    for key, nestedValue of value
      validate placeholder.value-type, nestedValue, (err) -> get-error-string "[#{key}]: #{err}"


module.exports = {create-placeholder, is-placeholder, get-type, validate}
