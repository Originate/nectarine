require! {
  './': Logger
}


default-options = logger: console


module.exports = (user-options) ->
  logger = new Logger {...default-options, ...user-options}
  logger.onUpdate
