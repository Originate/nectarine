require! {
  './schema-type': SchemaType
}

describe 'SchemaType' ->

  describe 'from-instance' ->

    specify 'identifies primatives' ->
      expect(SchemaType.from-instance []).to.equal SchemaType.ARRAY
      expect(SchemaType.from-instance false).to.equal SchemaType.BOOLEAN
      expect(SchemaType.from-instance ->).to.equal SchemaType.FUNCTION
      expect(SchemaType.from-instance 123).to.equal SchemaType.NUMBER
      expect(SchemaType.from-instance {}).to.equal SchemaType.OBJECT
      expect(SchemaType.from-instance 'fizz').to.equal SchemaType.STRING

    specify 'identifies custom types' ->
      class MyClass
      expect(SchemaType.from-instance(new MyClass).to-string!).to.equal 'MyClass'

    specify 'throws when passed undefined or null' ->
      expect(-> SchemaType.from-instance undefined).to.throw /Cannot create SchemaType from undefined or null/
      expect(-> SchemaType.from-instance null).to.throw /Cannot create SchemaType from undefined or null/


  describe 'normalize-type' ->

    specify 'works with strings of primative types' ->
      expect(SchemaType.normalize-type 'array').to.equal SchemaType.ARRAY
      expect(SchemaType.normalize-type 'boolean').to.equal SchemaType.BOOLEAN
      expect(SchemaType.normalize-type 'function').to.equal SchemaType.FUNCTION
      expect(SchemaType.normalize-type 'number').to.equal SchemaType.NUMBER
      expect(SchemaType.normalize-type 'object').to.equal SchemaType.OBJECT
      expect(SchemaType.normalize-type 'string').to.equal SchemaType.STRING

    specify 'works with primative constructors' ->
      expect(SchemaType.normalize-type Array).to.equal SchemaType.ARRAY
      expect(SchemaType.normalize-type Boolean).to.equal SchemaType.BOOLEAN
      expect(SchemaType.normalize-type Function).to.equal SchemaType.FUNCTION
      expect(SchemaType.normalize-type Number).to.equal SchemaType.NUMBER
      expect(SchemaType.normalize-type Object).to.equal SchemaType.OBJECT
      expect(SchemaType.normalize-type String).to.equal SchemaType.STRING


describe 'SchemaType' ->

  describe '#validate' ->

    specify 'does nothing if type is valid' ->
      SchemaType.ARRAY.validate []
      SchemaType.BOOLEAN.validate false
      SchemaType.FUNCTION.validate ->
      SchemaType.NUMBER.validate 123
      SchemaType.OBJECT.validate {}
      SchemaType.STRING.validate 'fizz'

    specify 'throws a helpful error if types missmatch' ->
      expect(-> SchemaType.ARRAY.validate false  ).to.throw 'false (type Boolean) does not match required type Array'
      expect(-> SchemaType.BOOLEAN.validate (->) ).to.throw 'function (){} (type Function) does not match required type Boolean'
      expect(-> SchemaType.FUNCTION.validate 123 ).to.throw '123 (type Number) does not match required type Function'
      expect(-> SchemaType.NUMBER.validate {}    ).to.throw '{} (type Object) does not match required type Number'
      expect(-> SchemaType.OBJECT.validate 'fizz').to.throw '"fizz" (type String) does not match required type Object'
      expect(-> SchemaType.STRING.validate []    ).to.throw '[] (type Array) does not match required type String'

    specify 'supports a custom error function' ->
      get-error-string = (err) -> "Custom err: #{err}"
      expect(-> SchemaType.ARRAY.validate false,   get-error-string).to.throw 'Custom err: false (type Boolean) does not match required type Array'
      expect(-> SchemaType.BOOLEAN.validate (->),  get-error-string).to.throw 'Custom err: function (){} (type Function) does not match required type Boolean'
      expect(-> SchemaType.FUNCTION.validate 123,  get-error-string).to.throw 'Custom err: 123 (type Number) does not match required type Function'
      expect(-> SchemaType.NUMBER.validate {},     get-error-string).to.throw 'Custom err: {} (type Object) does not match required type Number'
      expect(-> SchemaType.OBJECT.validate 'fizz', get-error-string).to.throw 'Custom err: "fizz" (type String) does not match required type Object'
      expect(-> SchemaType.STRING.validate [],     get-error-string).to.throw 'Custom err: [] (type Array) does not match required type String'

    specify 'works with custom classes' ->
      class MyClass
      class NotMyClass

      SchemaType.from-constructor(MyClass).validate new MyClass
      expect(->
        SchemaType.from-constructor(MyClass).validate new NotMyClass
      ).to.throw '{} (type NotMyClass) does not match required type MyClass'

    specify 'throws on null and undefined' ->
      expect(->
        SchemaType.ARRAY.validate null
      ).to.throw 'null does not match required type Array'
      expect(->
        SchemaType.ARRAY.validate undefined
      ).to.throw 'undefined does not match required type Array'
