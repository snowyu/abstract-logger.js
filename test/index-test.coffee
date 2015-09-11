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
  beforeEach ->TestLogger::_write.reset()

  describe '.constructor', ->
    it 'should get an instance', ->
      result = TestLogger('test')
      expect(result).to.be.instanceOf TestLogger
      expect(result).to.have.property 'name', 'test'
    it 'should get an instance via object argument', ->
      result = TestLogger(name: 'test')
      expect(result).to.be.instanceOf TestLogger
      expect(result).to.have.property 'name', 'test'
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
