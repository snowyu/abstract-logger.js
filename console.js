ConsoleLogger     = require('./lib/console')
SingleLineLogger  =  require('./lib/console/single-line')

module.exports = function (name){
  var result = ConsoleLogger(name)
  result.single = SingleLineLogger(name)
  return result
}