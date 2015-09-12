module.exports = result = SILENT: -1
logLevels = [
  'EMERGENCY'
  'ALERT'
  'CRITICAL'
  'ERROR'
  'WARNING'
  'NOTICE'
  'INFO'
  'DEBUG'
  'TRACE'
]
logLevels.forEach (v, i)->
  result[v]=i
