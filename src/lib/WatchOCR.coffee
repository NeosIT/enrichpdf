fs = require "fs"
fork = require('child_process').fork
spawn = require('child_process').spawn


class WatchOCR
  constructor: (@App, @FilePath, @paths) ->
    # Check the file
    console.log @FilePath
    setTimeout(@convertFile.bind(this), 200)

  convertFile: ->
    if @App.cfg.ocr.debug
      console.log "Forking..."
      cp = fork "../util/mock/img2pdf", [], silent:true
    else
      "do real stuff"
    cp.stdout.on "data", (dta) =>
      match = @pagerx.exec dta
      console.log dta
      if match
        console.log match
    cp.stdout.on "end", () =>
      console.log "END"



module.exports = WatchOCR