fs = require "fs"
fork = require('child_process').fork
spawn = require('child_process').spawn
pdf2pdf = require "pdf2pdf"
path = require "path"

class Enrich
  constructor: (@App, @ID, @FilePath, @OutPath) ->
    # Members
    @Status = "Init"
    @Done = false
    @Error = false


  # Initiate conversion
  convert: ->
    pdf2pdf.run
      infile: @FilePath
      outfile: @OutPath
      cb_status: @processCallback.bind(this)
    , @fileConverted.bind(this)
    @


  # Callback when conversion process is finished.
  fileConverted: (err) ->
    if err
      @Error = err
    else
      @Done = true
      console.log "Done!"
    @save()


  # Callback whenever conversion process advances.
  processCallback: (stat) ->
    @Status = stat
    console.log "Proc: " + stat
    @save()


  # Save this entity to file.
  save: ->
    fs.writeFileSync path.join(@App.cfg.ocr.store, @ID) + ".json", @serialize(), encoding:"utf8", flag:"w"
    @

  load: (callback) ->
    if @ID && typeof callback == "function"
      fpath = path.join(@App.cfg.ocr.store, @ID) + ".json"
      fs.exists fpath, (ex) ->
        return callback(new Error("Does not exist!"), null) unless ex
        fs.readFile fpath, encoding:"utf8", (err, dta) ->
          if err
            return callback(err, null)
          try
            pdat = JSON.parse dta
            @Status = pdat.status
            @Done = pdat.done
            @FilePath = pdat.original
            @OutPath = pdat.converted
            return callback(null, @)
          catch e
            return callback(new Error("Error parsing JSON!"), null)


  # Return a JSON serialized version of this object.
  serialize: ->
    JSON.stringify
      id: @ID
      status: @Status
      done: @Done
      error: @Error
      original: @FilePath
      converted: @OutPath


  # Class method, generates a unique ID for the process.
  @generateUniqueID: ->
    (Math.floor(Math.random()*100000000)).toString(36) + (+new Date()).toString(36)



module.exports = Enrich