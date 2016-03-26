## abstract-logger [![npm](https://img.shields.io/npm/v/abstract-logger.svg)](https://npmjs.org/package/abstract-logger)

[![Build Status](https://img.shields.io/travis/snowyu/abstract-logger.js/master.svg)](http://travis-ci.org/snowyu/abstract-logger.js)
[![Code Climate](https://codeclimate.com/github/snowyu/abstract-logger.js/badges/gpa.svg)](https://codeclimate.com/github/snowyu/abstract-logger.js)
[![Test Coverage](https://codeclimate.com/github/snowyu/abstract-logger.js/badges/coverage.svg)](https://codeclimate.com/github/snowyu/abstract-logger.js/coverage)
[![downloads](https://img.shields.io/npm/dm/abstract-logger.svg)](https://npmjs.org/package/abstract-logger)
[![license](https://img.shields.io/npm/l/abstract-logger.svg)](https://npmjs.org/package/abstract-logger)


It is an abstract logger class.

## Usage


```coffee
Logger    = require 'abstract-logger'
inherits  = require 'inherits-ex'

class MyLogger
  inherits MyLogger, Logger

  constructor: ->super
  # The `_write` method need to be overwrote.
  _write: (str)->console.error str
```


```js
var logger = new MyLogger('test')
logger.log({
  message: '${name} - ${level}: here is a %s logging "${title}"!'
  , title: 'Today news'
  , level: log.levels.ERROR
}, 'pretty')
//or:
logger.log('${name} - ${level}: here is a %s logging "${title}"!', {
    title: 'Today news'
  , level: log.levels.ERROR
}, 'pretty')
//result: 'test - ERROR: here is a pretty logging "Today news"'
```

## API

* Methods:
  * `log(message[, context], args...)`:eg, log('hi ${user}', {user:'Mikey'})
    * message *(String)*: The message to show up
    * context *(Object)*: The optional context to escape the message against and pass the options to the log:
      * level *(Number|String)*: the logLevel. it will be translated to the string if it's a number
      * label *(String)*: the status label.
      * name *(String)*: the logger name if exists.
  * `log(context, args...)`:eg, log({message:'${name} - ${level}: hi ${user}', level:'info', user:'Mikey'})
    * The context to escape the message against and pass the options to the log:
      * message *(String)*: The message to show up
      * level *(Number|String)*: the logLevel. it will be translated to the string if it's a number
      * label *(String)*: the status label.
      * name *(String)*: the logger name if exists.
  * `write(...)`: write a new-line if no arguments.
  * `writeln(...)`: Same as `log.write()` but automatically appends a `\n` at the end
    of the message.
  * `emergency/alert/critical/error/warning/notice/info/debug/trace(message[, context], args...)`:
    * log the specified level message.


## TODO

+ Stream with transport (like https://github.com/winstonjs/winston)

## Changes

### v0.2

+ `enabled` *(Boolean)*: enable/disable the logger. default to true.
+ `levels` *(LogLevels)*: customizable logging levels
  + The default LogLevels:
    * SILENT:-1
    * EMERGENCY:0 system is unusable
    * ALERT:1     action must be taken immediately
    * CRITICAL:2  the system is in critical condition
    * ERROR:3     error condition
    * WARNING:4   warning condition
    * NOTICE:5    a normal but significant condition
    * INFO:6      a purely informational message
    * DEBUG:7     messages to debug an application
+ `level`: use the property to get/set the log level.
  * defaults to levels.ERROR.
  * set `'SILENT'` to mute the loglevel msg, it will still print it out if the msg without loglevel.
  * setter *(Nubmer|String)*: set the logging level via number or string.
  * getter *(String)*: get the logging level string, or get the level number via `_level` property.
* `log()`
  + level, name options to context.
  + log(context, args...)

## License

MIT
