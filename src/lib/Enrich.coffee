fs = require "fs"
fork = require('child_process').fork
spawn = require('child_process').spawn
pdf2pdf = require "pdf2pdf"

class Enrich
  constructor: (@App, @FilePath, @paths) ->
    # Check the file
    console.log @FilePath
    setTimeout(@convertFile.bind(this), 200)

  convertFile: ->
    console.log "!"



module.exports = Enrich