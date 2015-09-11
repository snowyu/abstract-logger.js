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

## API

* Methods:
  * `log(message, context)`:eg, log('hi ${user}', {user:'Mikey'})
  * `write(...)`: write a new-line if no arguments.
  * `writeln(...)`: Same as `log.write()` but automatically appends a `\n` at the end
    of the message.


## TODO

+ LogLevel
  * 0 EMERGENCY system is unusable
  * 1 ALERT action must be taken immediately
  * 2 CRITICAL the system is in critical condition
  * 3 ERROR error condition
  * 4 WARNING warning condition
  * 5 NOTICE a normal but significant condition
  * 6 INFO a purely informational message
  * 7 DEBUG messages to debug an application
+ Stream with transport (like https://github.com/winstonjs/winston)

## License

MIT
