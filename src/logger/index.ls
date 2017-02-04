require! {
  './helpers': {get-transition, get-value, merge-updates}
}


class Logger

  ({@logger}) ->
    @_queue = []


  onUpdate: (new-value, old-value, path-array, meta) ~>
    @_queue.push {meta, new-value, old-value, path-array}
    if @_queue.length is 1
      set-timeout @_drainQueue


  _drainQueue: ~>
    last-batch-id = null
    group = []
    print-last-group = ~>
      return if group.length is 0
      @_print mergeUpdates(group)
      group := []

    for update in @_queue
      batch-id = update.meta?.batch-id
      if batch-id isnt last-batch-id then print-last-group()
      if batch-id
        last-batch-id = batch-id
        group.push update
      else
        @_print update

    print-last-group()
    @_queue = []


  _print: ({new-value, old-value, path-array}) ->
    @logger.group-collapsed "#{path-array.join('.')}: #{get-transition {new-value, old-value}}"
    @logger.log '%c old:', 'color: red', get-value(old-value)
    @logger.log '%c new:', 'color: green', get-value(new-value)
    @logger.group-end()


module.exports = Logger
