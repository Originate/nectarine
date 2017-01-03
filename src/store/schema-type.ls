class SchemaType

  (@_type) ->
    unless @_type is \any or typeof @_type is \function
      throw new Error 'Type must be the string "any" or a constructor'


  validate: (value, get-error-string = -> it) ->
    unless value |> @is-valid
      got = if value?.constructor in [Function, RegExp]
        "#{String value} (type #{value.constructor.name})"
      else if value?
        "#{JSON.stringify value} (type #{value.constructor.name})"
      else
        String(value)
      throw new Error get-error-string "#{got} does not match required type #{@to-string!}"


  is-valid: (thing) ->
    @_type is \any or thing?.constructor is @_type


  value-of: ->
    @to-string!


  to-string: ->
    | @_type is \any => 'any'
    | otherwise      => @_type.name


  @@ANY      = new SchemaType \any
  @@ARRAY    = new SchemaType Array
  @@BOOLEAN  = new SchemaType Boolean
  @@FUNCTION = new SchemaType Function
  @@NUMBER   = new SchemaType Number
  @@OBJECT   = new SchemaType Object
  @@STRING   = new SchemaType String


  @@from-constructor = (Constructor) ->
    switch Constructor
    | Array     => @@ARRAY
    | Boolean   => @@BOOLEAN
    | Function  => @@FUNCTION
    | Number    => @@NUMBER
    | Object    => @@OBJECT
    | String    => @@STRING
    | otherwise => new SchemaType Constructor


  @@from-instance = (instance) ->
    throw new Error 'Cannot create SchemaType from undefined or null' unless instance?
    @@from-constructor instance.constructor


  @@normalize-type = (type) ->
    switch typeof type
    | \string   => @@[type.to-upper-case!] ? throw Error "Unknown type #{type}"
    | \function => @@from-constructor(type)
    | otherwise => throw new Error "Cannot normalize type #{type}: must be a string or constructor"


module.exports = SchemaType
