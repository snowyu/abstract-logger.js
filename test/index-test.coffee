chai            = require 'chai'
sinon           = require 'sinon'
sinonChai       = require 'sinon-chai'
should          = chai.should()
expect          = chai.expect
assert          = chai.assert
chai.use(sinonChai)

setImmediate    = setImmediate || process.nextTick

inherits          = require 'inherits-ex/lib/inherits'
createObject      = require 'inherits-ex/lib/createObjectWith'
format            = require 'util-ex/lib/format'
Logger            = require '../src'

class TestLogger
  inherits TestLogger, Logger

  constructor: ->
    return createObject TestLogger, arguments unless @ instanceof TestLogger
    super
  _write: sinon.spy (msg)->#console.log msg

describe 'AbstractLogger', ->
  log = TestLogger('test')
  beforeEach ->
    TestLogger::_write.reset()
    log.level = 'error'

  describe '.constructor', ->
    it 'should get an instance', ->
      result = TestLogger('test')
      expect(result).to.be.instanceOf TestLogger
      expect(result).to.have.property 'name', 'test'
    it 'should get an instance via object argument', ->
      result = TestLogger(name: 'test')
      expect(result).to.be.instanceOf TestLogger
      expect(result).to.have.property 'name', 'test'
    it 'should customize log levels', ->
      lvls = {}
      result = TestLogger(name: 'test', levels:lvls)
      expect(result.levels).to.be.equal lvls
    it 'should init a log level', ->
      result = TestLogger(name: 'test', level: 'notice')
      expect(result.level).to.be.equal 'NOTICE'
      expect(result._level).to.be.equal log.levels.NOTICE
    it 'should disable a logger', ->
      result = TestLogger(name: 'test', enabled: false)
      expect(result.enabled).to.be.false
      result.log 'his'
      expect(TestLogger::_write).to.be.not.called

  describe '#formatter', ->
    it 'should format a string', ->
      result = log.formatter
        message: '${name} - ${level}: hi ${user}: %s'
        user: 'Mikey'
        level: log.levels.ERROR
      , 'ok'
      expect(result).to.be.equal 'test - 3: hi Mikey: ok'

  describe '#write', ->
    it 'should write a string', ->
      msg = 'hi here'
      log.write msg
      expect(TestLogger::_write).to.be.calledOnce
      expect(TestLogger::_write).to.be.calledWith msg
    it 'should write a new line', ->
      log.write()
      expect(TestLogger::_write).to.be.calledOnce
      expect(TestLogger::_write).to.be.calledWith log.NEWLINE
    it 'should write multi-arguments', ->
      msg = ['hi here', [12,34], {a:1,b:2}]
      log.write.apply(log, msg)
      msg = format.apply(null, msg)
      expect(TestLogger::_write).to.be.calledOnce
      expect(TestLogger::_write).to.be.calledWith msg

  describe '#writeln', ->
    it 'should writeln a string', ->
      msg = 'hi here'
      log.writeln msg
      expect(TestLogger::_write).to.be.calledTwice
      expect(TestLogger::_write).to.be.calledWith msg
      expect(TestLogger::_write).to.be.calledWith log.NEWLINE
    it 'should write a new line', ->
      log.writeln()
      expect(TestLogger::_write).to.be.calledTwice
      expect(TestLogger::_write).to.be.calledWith log.NEWLINE
    it 'should write multi-arguments', ->
      msg = ['hi here', [12,34], {a:1,b:2}]
      log.writeln.apply(log, msg)
      msg = format.apply(null, msg)
      expect(TestLogger::_write).to.be.calledTwice
      expect(TestLogger::_write).to.be.calledWith msg
      expect(TestLogger::_write).to.be.calledWith log.NEWLINE
  describe '#log', ->
    it 'should log message, context', ->
      log.log 'hi ${    user }! ${user}. ${no', user:'Mikey'
      expect(TestLogger::_write).to.be.calledTwice
      expect(TestLogger::_write).to.be.calledWith 'hi Mikey! Mikey. ${no'

    it 'should log multi arguments', ->
      log.log 'hi user:%s, num:%d!', 'Mikey', 123
      expect(TestLogger::_write).to.be.calledTwice
      expect(TestLogger::_write).to.be.calledWith 'hi user:Mikey, num:123!'

    it 'should log a message with level', ->
      log.log '${name} - ${level}: hi ${user}: %s',
        user: 'Mikey'
        level: log.levels.ERROR
      , 'ok'
      expect(TestLogger::_write).to.be.calledTwice
      expect(TestLogger::_write).to.be.calledWith 'test - ERROR: hi Mikey: ok'

    it 'should log a message without level', ->
      log.log '${name}: hi ${user}: %s',
        user: 'Mikey'
      , 'ok'
      expect(TestLogger::_write).to.be.calledTwice
      expect(TestLogger::_write).to.be.calledWith 'test: hi Mikey: ok'

    it 'should log a message with level string', ->
      log.log '${name} - ${level}: hi ${user}: %s',
        user: 'Mikey'
        level: 'error'
      , 'ok'
      expect(TestLogger::_write).to.be.calledTwice
      expect(TestLogger::_write).to.be.calledWith 'test - error: hi Mikey: ok'
    it 'should log a message with level via single object', ->
      log.log
        message: '${name} - ${level}: hi ${user}: %s %s'
        user: 'Mikey'
        level: log.levels.ERROR
      , 'ok', 'world'
      expect(TestLogger::_write).to.be.calledTwice
      expect(TestLogger::_write).to.be.calledWith 'test - ERROR: hi Mikey: ok world'
    it 'should log a message without level via single object', ->
      log.log
        message: '${name} - ${level}: hi ${user}: %s'
        user: 'Mikey'
        level: 'ERROR'
      , 'ok'
      expect(TestLogger::_write).to.be.calledTwice
      expect(TestLogger::_write).to.be.calledWith 'test - ERROR: hi Mikey: ok'
    it 'should mute a message with loglevel', ->
      log.level = log.levels.ERROR-1
      expect(log.level).to.be.equal 'CRITICAL'
      log.log
        message: '${name} - ${level}: hi ${user}: %s %s'
        user: 'Mikey'
        level: log.levels.ERROR
      , 'ok', 'world'
      expect(TestLogger::_write).to.not.be.called
    it 'should mute a message with loglevel string', ->
      log.level = log.levels.ERROR-1
      log.log
        message: '${name} - ${level}: hi ${user}: %s %s'
        user: 'Mikey'
        level: 'error'
      , 'ok', 'world'
      expect(TestLogger::_write).to.not.be.called
    it 'should be silent with any loglevel string', ->
      log.level = log.levels.SILENT
      for k,v of log.levels
        continue if v is -1
        log.log
          message: '${name} - ${level}: hi ${user}: %s %s'
          user: 'Mikey'
          level: k
        , 'ok', 'world'
      expect(TestLogger::_write).to.not.be.called


  describe '#inspect', ->
    it 'should inspect', ->
      result = log.inspect()
      expect(result).to.be.equal '<TestLogger "test">'
      result = TestLogger().inspect()
      expect(result).to.be.equal '<TestLogger>'

  describe 'NEWLINE', ->
    it 'should change newLine char', ->
      result = TestLogger(name: 'test', newLine:'a')
      expect(result).to.be.instanceOf TestLogger
      expect(result).to.have.property 'name', 'test'
      expect(result).to.have.property 'NEWLINE', 'a'
      result.write()
      expect(TestLogger::_write).to.be.calledOnce
      expect(TestLogger::_write).to.be.calledWith 'a'

  describe '#toJSON', ->
    it 'should JSON.stringify a logger object', ->
      result = JSON.stringify log
      expect(result).to.be.equal '{"level":"ERROR","enabled":true}'

  for k, id of log.levels
    continue if id is -1
    ( (act, aId)->
      describe '#'+act, ->
        beforeEach -> log.level = aId
        it 'should log message', ->
          log[act] 'hi world', 'ok'
          expect(TestLogger::_write).to.be.calledTwice
          expect(TestLogger::_write).to.be.calledWith 'hi world ok'

        it 'should log message, context', ->
          log[act] 'hi ${    user }! ${user}. ${no', user:'Mikey'
          expect(TestLogger::_write).to.be.calledTwice
          expect(TestLogger::_write).to.be.calledWith 'hi Mikey! Mikey. ${no'

        it 'should log multi arguments', ->
          log[act] 'hi user:%s, num:%d!', 'Mikey', 123
          expect(TestLogger::_write).to.be.calledTwice
          expect(TestLogger::_write).to.be.calledWith 'hi user:Mikey, num:123!'

        it 'should log a message with level', ->
          log[act] '${name} - ${level}: hi ${user}: %s',
            user: 'Mikey'
          , 'ok'
          expect(TestLogger::_write).to.be.calledTwice
          expect(TestLogger::_write).to.be.calledWith 'test - '+act.toUpperCase()+': hi Mikey: ok'
        it 'should log a message with level via single object', ->
          log[act]
            message: '${name} - ${level}: hi ${user}: %s %s'
            user: 'Mikey'
          , 'ok', 'world'
          expect(TestLogger::_write).to.be.calledTwice
          expect(TestLogger::_write).to.be.calledWith 'test - '+act.toUpperCase()+': hi Mikey: ok world'

    )(k.toLowerCase(), id)
