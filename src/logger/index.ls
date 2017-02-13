require! {
  './helpers': {get-transition, get-value, merge-updates}
}


class Logger

  ({@logger}) ->
    @_queue = []


  onUpdate: ({path, updates}) ~>
    @_queue.push {path, updates}
    if @_queue.length is 1
      set-timeout @_drainQueue


  _drainQueue: ~>
    for {path, updates} in @_queue
      @_print merge-updates {path, updates}
    @_queue = []


  _print: ({new-values, old-values, path}) ->
    @logger.group-collapsed "#{path.join('.')}: #{get-transition {new-values, old-values}}"
    @logger.log '%c old:', 'color: red', get-value(old-values)
    @logger.log '%c new:', 'color: green', get-value(new-values)
    @logger.group-end()


module.exports = Logger
