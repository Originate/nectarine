require! {
  './schema-placeholder'
  './store-node': StoreNode
}


class StoreLeaf extends StoreNode

  ->
    super ...
    @$reset!


  $get: ->
    if @_error?
      error-string = if @_error instanceof Error then @_error.message else @_error
      throw Error "Error getting `#{@$get-path-string!}`. #{@_key}: has error #{JSON.stringify error-string}"

    if @_loading
      throw Error "Error getting `#{@$get-path-string!}`. #{@_key}: is loading"

    @_data


  $get-error: ->
    @_error


  $is-loading: ->
    @_loading


  $from-promise: (promise)->
    @$set-loading!
    promise
      .then (data) ~>
        @$set data
      .catch (err) ~>
        @$set-error err
        Promise.reject err


  $reset: ->
    @$set @_schema.initial-value ? null


  $set: (data) !->
    schema-placeholder.validate @_schema, data, (err) ~>
      "Error setting `#{@$get-path-string!}`. #{@_key}: #{err}"

    @_update {data, loading: no, error: null}


  $set-error: (error) !->
    @_update {data: null, loading: no, error}


  $set-loading: (loading = yes) !->
    @_update {data: null, loading, error: null}


  _update: (new-values) ->
    old-values = data: @_data, loading: @_loading, error: @_error
    @_data = new-values.data
    @_loading = new-values.loading
    @_error = new-values.error
    @$emit-update new-values, old-values, @$get-path!


module.exports = StoreLeaf
