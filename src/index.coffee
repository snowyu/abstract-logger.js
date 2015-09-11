isObject      = require 'util-ex/lib/is/type/object'
isString      = require 'util-ex/lib/is/type/string'
format        = require 'util-ex/lib/format'
#extend        = require 'util-ex/lib/extend'

# TODO:
#   * LogLevel
#     0 EMERGENCY system is unusable
#     1 ALERT action must be taken immediately
#     2 CRITICAL the system is in critical condition
#     3 ERROR error condition
#     4 WARNING warning condition
#     5 NOTICE a normal but significant condition
#     6 INFO a purely informational message
#     7 DEBUG messages to debug an application
#   * Stream with transport (like https://github.com/winstonjs/winston)
module.exports = class AbstractLogger

  constructor: (aName, aOptions)->
    if isObject aName
      aOptions = aName
      aName = aOptions.name
    @name = aName if aName
    if isObject aOptions
      @NEWLINE = aOptions.newLine if aOptions.newLine and aOptions.newLine.length
    #   extend @, aOptions, (k)->not (k in ['name'])

  NEWLINE: '\n'

  ### !pragma coverage-skip-next ###
  _write:-> throw Error 'NOT IMPL'

  # eg,
  #  str = formatter msg: 'new fancy %method for %url', method:'GET', url:'http://www.google.com'
  formatter: (msg, ctx) ->
    end = -1
    start = msg.indexOf('${')
    while start isnt -1 and end < msg.length
      end = msg.indexOf('}', start)
      end = msg.length if end is -1
      v = msg.slice(start + 2, end).trim()
      v = ctx[v]
      if v?
        v = v.toString()
        msg = msg.slice(0, start) + v + msg.slice(end+1)
        end = start+v.length
      start = msg.indexOf('${', ++end)
    msg

  # Log functions take two arguments, a message and a context. For any
  # other kind of paramters, through these to writeln, so all of the
  # console format string goodies you're used to work fine.
  #
  # - message  - The message to show up
  # - context  - The optional context to escape the message against
  #
  # Returns the logger
  log: (message, context) ->
    if isString(message) and isObject(context) and not Array.isArray(context)
      @writeln @formatter(message, context)
    else
      @writeln.apply this, arguments
    @

  # A simple write method, with formatted message. If `msg` is
  # ommitted, then a single `\n` is written.
  #
  # Returns the logger
  write: ->
    vStr = if arguments.length then format.apply(null, arguments) else @NEWLINE
    @_write vStr
    @


  # Same as `log.write()` but automatically appends a `\n` at the end
  # of the message.
  writeln: ->
    @write.apply(this, arguments).write()

  _inspect: ->
    result = if @name then '"' + @name + '"' else ''
  inspect: ->
    result = @Class.name || @constructor.name
    vAttrs = @_inspect()
    result += ' ' + vAttrs if vAttrs
    '<' + result + '>'