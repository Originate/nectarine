require! {
  './schema-placeholder': {is-placeholder, create-placeholder: __, get-type, validate}
  './schema-type': SchemaType
}

describe 'schema-place-holder' ->

  describe 'is-placeholder' ->

    specify 'returns true if it is a default placeholder' ->
      expect(is-placeholder __).to.be.true

    specify 'returns true if it is a non-default placeholder' ->
      expect(is-placeholder __(type: 'string')).to.be.true

    specify 'returns false for non-placeholders' ->
      expect(is-placeholder {}).to.be.false


  describe 'get-type' ->

    specify 'it throws an error if passed a non-placeholder' ->
      expect ->
        get-type {}
      .to.throw /is not a placeholder/

    specify 'returns "any" if it is a default placeholder' ->
      expect(get-type __).to.equal SchemaType.ANY

    specify 'returns "any" if type or initial value is not defined' ->
      expect(get-type __!).to.equal SchemaType.ANY

    specify 'returns type of initial-value if type is not defined' ->
      expect(get-type __(initial-value: [])).to.equal SchemaType.ARRAY
      expect(get-type __(initial-value: true)).to.equal SchemaType.BOOLEAN
      expect(get-type __(initial-value: 123)).to.equal SchemaType.NUMBER
      expect(get-type __(initial-value: {})).to.equal SchemaType.OBJECT
      expect(get-type __(initial-value: 'foo')).to.equal SchemaType.STRING

    specify 'returns type if specified as a constructor' ->
      expect(get-type __(type: Array)).to.equal SchemaType.ARRAY
      expect(get-type __(type: Boolean)).to.equal SchemaType.BOOLEAN
      expect(get-type __(type: Number)).to.equal SchemaType.NUMBER
      expect(get-type __(type: Object)).to.equal SchemaType.OBJECT
      expect(get-type __(type: String)).to.equal SchemaType.STRING

    specify 'returns type if specified as a string' ->
      expect(get-type __(type: \any)).to.equal SchemaType.ANY
      expect(get-type __(type: \array)).to.equal SchemaType.ARRAY
      expect(get-type __(type: \boolean)).to.equal SchemaType.BOOLEAN
      expect(get-type __(type: \number)).to.equal SchemaType.NUMBER
      expect(get-type __(type: \object)).to.equal SchemaType.OBJECT
      expect(get-type __(type: \string)).to.equal SchemaType.STRING

    specify 'returns type "any" if specified even with initial-value' ->
      expect(get-type __(type: \any, initial-value: [])).to.equal SchemaType.ANY
      expect(get-type __(type: \any, initial-value: false)).to.equal SchemaType.ANY
      expect(get-type __(type: \any, initial-value: 123)).to.equal SchemaType.ANY
      expect(get-type __(type: \any, initial-value: {})).to.equal SchemaType.ANY
      expect(get-type __(type: \any, initial-value: "foo")).to.equal SchemaType.ANY


  describe 'validation' ->

    describe 'allow-null validation' ->

      specify 'throws an error if allow-null is false and no initial value is provided' ->
        expect(-> __(allow-null: no)).to.throw 'initialValue is required when setting allowNull to false'

      specify 'throws an error when attempting to set null or undefined and allow-null is false' ->
        p = __ allow-null: no, initial-value: []
        expect(-> validate p, null).to.throw 'null fails non-null constraint'
        expect(-> validate p, undefined).to.throw 'undefined fails non-null constraint'


    describe 'type validation' ->

      specify 'throws an error if initial-value does not match type' ->
        expect(-> __(initial-value: false, type: \array)).to.throw 'initialValue: false (type Boolean) does not match required type Array'
        expect(-> __(initial-value: 123, type: \boolean)).to.throw 'initialValue: 123 (type Number) does not match required type Boolean'
        expect(-> __(initial-value: {}, type: \number)).to.throw 'initialValue: {} (type Object) does not match required type Number'
        expect(-> __(initial-value: 'foo', type: \object)).to.throw 'initialValue: "foo" (type String) does not match required type Object'
        expect(-> __(initial-value: [], type: \string)).to.throw 'initialValue: [] (type Array) does not match required type String'

      specify 'throws an error if validate is not a function or regexp' ->
        expect(-> __(validate: [])).to.throw 'validate must be a function or regular expression'
        expect(-> __(validate: false)).to.throw 'validate must be a function or regular expression'
        expect(-> __(validate: 123)).to.throw 'validate must be a function or regular expression'
        expect(-> __(validate: {})).to.throw 'validate must be a function or regular expression'

      specify 'throws an error if validate is regexp and type isnt string' ->
        expect(-> __(validate: /a/)).to.throw 'validate must be a function if type isnt string'
        expect(-> __(type: \any, validate: /a/)).to.throw 'validate must be a function if type isnt string'
        expect(-> __(type: Array, validate: /a/)).to.throw 'validate must be a function if type isnt string'
        expect(-> __(type: Boolean, validate: /a/)).to.throw 'validate must be a function if type isnt string'
        expect(-> __(type: Number, validate: /a/)).to.throw 'validate must be a function if type isnt string'
        expect(-> __(type: Object, validate: /a/)).to.throw 'validate must be a function if type isnt string'

        expect(-> __(initial-value: [], validate: /a/)).to.throw 'validate must be a function if type isnt string'
        expect(-> __(initial-value: false, validate: /a/)).to.throw 'validate must be a function if type isnt string'
        expect(-> __(initial-value: 123, validate: /a/)).to.throw 'validate must be a function if type isnt string'
        expect(-> __(initial-value: {}, validate: /a/)).to.throw 'validate must be a function if type isnt string'

      specify 'succeeds if type is any' ->
        validate __(type: \any), null
        validate __(type: \any), undefined
        validate __(type: \any), []
        validate __(type: \any), false
        validate __(type: \any), 123
        validate __(type: \any), {}
        validate __(type: \any), 'foo'

      specify 'succeeds if type matches specified type' ->
        validate __(type: Array), []
        validate __(type: Boolean), false
        validate __(type: Number), 123
        validate __(type: Object), {}
        validate __(type: String), 'foo'

      specify 'Allows setting null & undefined' ->
        validate __(type: Array), null
        validate __(type: Array), undefined
        validate __(type: Boolean), null
        validate __(type: Boolean), undefined
        validate __(type: Number), null
        validate __(type: Number), undefined
        validate __(type: Object), null
        validate __(type: Object), undefined
        validate __(type: String), null
        validate __(type: String), undefined

      specify 'throws an error if type does not match specified type' ->
        expect(-> validate __(type: Array), false).to.throw 'false (type Boolean) does not match required type Array'
        expect(-> validate __(type: Boolean), 123).to.throw '123 (type Number) does not match required type Boolean'
        expect(-> validate __(type: Number), {}).to.throw '{} (type Object) does not match required type Number'
        expect(-> validate __(type: Object), 'foo').to.throw '"foo" (type String) does not match required type Object'
        expect(-> validate __(type: String), []).to.throw '[] (type Array) does not match required type String'


    describe 'regex validation' ->

      specify 'does not throw an error if value validates' ->
        p = __ type: \string, validate: /@/
        validate p, 'email@example.com'

      specify 'throws an error if value fails to validate' ->
        p = __ type: \string, validate: /@/
        expect(-> validate p, 'foo').to.throw '"foo" does not validate /@/'

      specify 'does not throw an error if initial-value validates' ->
        __ initial-value: 'email@example.com', validate: /@/

      specify 'throws an error if initial-value fails to validate' ->
        expect(-> __ initial-value: 'foo', validate: /@/).to.throw 'initialValue: "foo" does not validate /@/'


    describe 'function validation' ->

      before-each ->
        @is-color = function is-color
          it in <[red green blue]>

      specify 'does not throw an error if value validates' ->
        p = __ validate: @is-color
        validate p, 'green'

      specify 'throws an error if value fails to validate' ->
        p = __ validate: @is-color
        expect(-> validate p, 'not-color').to.throw /"not-color" does not validate function isColor/

      specify 'does not throw an error if initial-value validates' ->
        __ validate: @is-color, initial-value: 'red'

      specify 'throws an error if initial-value fails to validate' ->
        expect(~> __ validate: @is-color, initial-value: 'not-color').to.throw /initialValue: "not-color" does not validate function isColor/


  describe 'array element types', ->

    describe 'simple type', ->
      before-each ->
        @placeholder = __({type: Array, elementType: __(type: 'string')})

      specify 'does not throw if each element adheres to the element type' ->
        validate @placeholder, ['a']

      specify 'throws an error if a child object has the wrong type' ->
        expect(~> validate @placeholder, [1]).to.throw '[0]: 1 (type Number) does not match required type String'

    describe 'nested object: shape', ->
      before-each ->
        todoType =
          completed: __(type: 'boolean')
          text: __(type: 'string')

        @placeholder = __({type: Array, elementType: __(type: 'object', shape: todoType)})

      specify 'does not throw if each element adheres to the element type' ->
        validate @placeholder, [{completed: true, text: 'write code'}]

      specify 'throws an error if a child object has the wrong type' ->
        expect(~>
          validate @placeholder, [{completed: 'Yes', text: 'write code'}]
        ).to.throw '[0]: [completed]: "Yes" (type String) does not match required type Boolean'


  describe 'object value type', ->

    describe 'simple type', ->
      before-each ->
        @placeholder = __({type: Object, valueType: __(type: 'number')})

      specify 'does not throw if each element adheres to the element type' ->
        validate @placeholder, {a: 1}

      specify 'throws an error if a child object has the wrong type' ->
        expect(~> validate @placeholder, {a: 'b'}).to.throw '[a]: "b" (type String) does not match required type Number'

    describe 'nested object: shape', ->
      before-each ->
        todoType =
          completed: __(type: 'boolean')
          text: __(type: 'string')

        @placeholder = __({type: Object, valueType: __(type: 'object', shape: todoType)})

      specify 'does not throw if each element adheres to the value type' ->
        validate @placeholder, {'id1': {completed: true, text: 'write code'}}

      specify 'throws an error if a child object has the wrong type' ->
        expect(~>
          validate @placeholder, {'id1': {completed: 'Yes', text: 'write code'}}
        ).to.throw '[id1]: [completed]: "Yes" (type String) does not match required type Boolean'
