require! {
  './schema-placeholder'
  './schema-type': SchemaType
  './store-node': StoreNode
}


class StoreLeaf extends StoreNode

  ({schema: @_schema})->
    super ...
    @$reset!


  $debug: ->
    data: @_data, loading: @_loading, error: @_error


  $from-promise: (promise)->
    @$set-loading!
    promise
      .then (data) ~>
        @$set data
      .catch (err) ~>
        @$set-error err
        Promise.reject err


  $get: ->
    if @_error?
      error-string = if @_error instanceof Error then @_error.message else @_error
      throw Error "Error getting `#{@$get-path-string!}`: has error #{JSON.stringify error-string}"

    if @_loading
      throw Error "Error getting `#{@$get-path-string!}`: is loading"

    @_data


  $get-error: ->
    @_error


  $has-data: ->
    @_data isnt null


  $is-loading: ->
    @_loading


  $reset: ->
    @$set @_schema.initial-value ? null


  $set: (data) !->
    schema-placeholder.validate @_schema, data, (err) ~>
      "Error setting `#{@$get-path-string!}`: #{err}"

    if data is @_data and schema-placeholder.get-type(@_schema) in [SchemaType.ARRAY, SchemaType.OBJECT]
      throw new Error "Error setting `#{@$get-path-string!}`: attempting to update to the same object. Always pass in a new object"

    @_update {data, loading: no, error: null}


  $set-error: (error) !->
    @_update {data: null, loading: no, error}


  $set-loading: (loading = yes) !->
    @_update {data: null, loading, error: null}


  _update: (new-values) ->
    old-values = @$debug!
    @_data = new-values.data
    @_loading = new-values.loading
    @_error = new-values.error
    @$emit-update path: @$get-path!, updates: [{new-values, old-values, path: @$get-path!}]


module.exports = StoreLeaf
