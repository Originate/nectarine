require! {
  './schema-placeholder'
  './store-node': StoreNode
}


class StoreLeaf extends StoreNode

  ->
    super ...
    @_loading = no
    @_data = @_schema.initial-value ? null
    @_error = null


  $get: ->
    if @_error?
      error-string = if @_error instanceof Error then @_error.message else @_error
      throw Error "Error getting `#{@_path.join '.'}`. #{@_path[*-1]}: has error #{JSON.stringify error-string}"

    if @_loading
      throw Error "Error getting `#{@_path.join '.'}`. #{@_path[*-1]}: is loading"

    @_data


  $get-error: ->
    @_error


  $is-loading: ->
    @_loading


  $from-promise: ->
    new Promise ->


  $set: (data) !->
    schema-placeholder.validate @_schema, data, (err) ~>
      "Error setting `#{@_path.join '.'}`. #{@_path[*-1]}: #{err}"

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
    @$emit-update new-values, old-values, @_path


module.exports = StoreLeaf
