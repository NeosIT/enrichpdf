fs = require "fs"
spawn = require('child_process').spawn


class WatchOCR
  constructor: (@App, @FilePath, @cfg) ->
    # Check the file
    setTimeout(@checkFile.bind(this), 1000)

  checkFile: ->
    if @cfg.debug
      pdfinfo = spawn @cfg.pdfinfo.command
      pdfinfo.stdout.pipe process.stdout


module.exports = WatchOCR