isObject        = require 'util-ex/lib/is/type/object'
isString        = require 'util-ex/lib/is/type/string'
isNumber        = require 'util-ex/lib/is/type/number'
isArray         = require 'util-ex/lib/is/type/array'
format          = require 'util-ex/lib/format'
defineProperty  = require 'util-ex/lib/defineProperty'
logLevels       = require './log-levels'
#extend        = require 'util-ex/lib/extend'

# TODO:
#   * Stream with transport (like https://github.com/winstonjs/winston)
module.exports = class AbstractLogger

  constructor: (aName, aOptions)->
    if isObject aName
      aOptions = aName
      aName = aOptions.name
    @name = aName if aName
    if isObject aOptions
      @NEWLINE = aOptions.newLine if aOptions.newLine and aOptions.newLine.length
      @levels = aOptions.levels if aOptions.levels?
      @level = aOptions.level if aOptions.level?
      @enabled = aOptions.enabled if aOptions.enabled is false

  NEWLINE: '\n'

  (->
    for k, id of logLevels
      continue if id < 0
      AbstractLogger::[k.toLowerCase()] = ((aLevelId)->
        return (aContext, args...)->
          arg2 = args[0]
          if isString(aContext) and isObject(arg2) and not isArray(arg2)
            arg2.level = aLevelId
            if @inLevelContext arg2
              arg2.message = aContext
              @writeln @formatter.apply(@, args)
          else if isObject(aContext) and isString(aContext.message)
            aContext.level = aLevelId
            if @inLevelContext aContext
              @writeln @formatter.apply(@, arguments)
          else if @inLevel aLevelId
            @writeln.apply @, arguments
          @
      )(id)
  )()

  levels: logLevels
  defineProperty @::, '_level', logLevels.ERROR
  defineProperty @::, 'level', undefined,
    get: -> @levelId2Str @_level
    set: (value)->
      if isString value
        @_level = @levelStr2Id value
      else if isNumber value
        @_level = value
      return

  ### !pragma coverage-skip-next ###
  _write:-> throw Error 'NOT IMPL'

  levelId2Str: (aId)->
    for vLevelStr, i of @levels
      if i is aId
        result = vLevelStr
        break
    result
  levelStr2Id: (aStr)-> @levels[aStr.toUpperCase()]

  # eg,
  #  str = formatter message: 'new fancy %method for %url', method:'GET', url:'http://www.google.com'
  formatter: (aContext, args...) ->
    msg = aContext.message
    end = -1
    start = msg.indexOf('${')
    aContext.name = @name if !aContext.name? and @name?
    while start isnt -1 and end < msg.length
      end = msg.indexOf('}', start)
      end = msg.length if end is -1
      v = msg.slice(start + 2, end).trim()
      v = aContext[v]
      if v?
        v = v.toString()
        msg = msg.slice(0, start) + v + msg.slice(end+1)
        end = start+v.length
      start = msg.indexOf('${', ++end)
    if args.length
      args.unshift msg
      msg = format.apply null, args
    msg

  inLevel: (aLevel)->
    aLevel = @levelStr2Id(aLevel) if !isNumber aLevel
    result = isNumber(aLevel) and aLevel <= @_level
    result
  inLevelContext: (aContext)->
    vLevel = aContext.level
    result = true
    if vLevel?
      result = @inLevel vLevel
      if result and isNumber vLevel
        aContext.level = @levelId2Str vLevel
    result
  # Log functions take two arguments, a message and a context. For any
  # other kind of paramters, through these to writeln, so all of the
  # console format string goodies you're used to work fine.
  #
  # - message  - The message to show up
  # - context  - The context to escape the message against and pass the options to the log:
  #   * level: the logLevel
  #   * label: the status label: it should be a method name of this logger object.
  #
  # Returns the logger
  log: (aContext, args...) ->
    arg2 = args[0]
    if isString(aContext) and isObject(arg2) and not isArray(arg2)
      if @inLevelContext arg2
        arg2.message = aContext
        @writeln @formatter.apply(@, args)
    else if isObject(aContext) and isString(aContext.message)
      if @inLevelContext aContext
        @writeln @formatter.apply(@, arguments)
    else
      @writeln.apply @, arguments
    @

  # A simple write method, with formatted message. If `msg` is
  # ommitted, then a single `\n` is written.
  #
  # Returns the logger
  write: ->
    if @enabled isnt false
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
    result = @Class || @constructor
    result = result.name
    vAttrs = @_inspect()
    result += ' ' + vAttrs if vAttrs
    '<' + result + '>'
  toObject: ->level:@level, enabled: @enabled isnt false
  toJSON: ->@toObject()