fs = require "fs"
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
    @App.info "Enrich: Init PDF2PDF."
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
      @App.log "error", err.message, if err.stack then callstack:err.stack else null
    else
      @Done = true
      @Status = "Complete."
    @save()
    # Send eMail
    # TODO: Only send e-mail if recipient(s) given.
    setTimeout(@sendMail.bind(this), 3000)


  # Send email with attachment
  sendMail: ->
    # TODO: Implement recursive check for file presence before sending.
    @App.sendMail
      from: "laq@neos-it.de"
      to: "laq@neos-it.de"
      subject: "Success e-mail baby yeah!"
      text: "This is the successfully converted PDF."
      attachment: [
        path: @OutPath
        type: "application/pdf"
        name: "converted.pdf"
      ]
    , (err, msg) ->
      if err
        @App.log "error", err.message, if err.stack then callstack:err.stack else null


  # Callback whenever conversion process advances.
  processCallback: (stat) ->
    @App.info "Enrich process #" + @ID + " status: " + stat
    @Status = stat
    @save()


  # Save this entity to file.
  save: ->
    fs.writeFileSync path.join(@App.cfg.ocr.store, @ID) + ".json", @serialize(), encoding:"utf8", flag:"w"
    @

  load: (callback) ->
    if @ID && typeof callback == "function"
      fpath = path.join(@App.cfg.ocr.store, @ID) + ".json"
      fs.exists fpath, (ex) =>
        return callback(new Error("Does not exist!"), null) unless ex
        fs.readFile fpath, encoding:"utf8", (err, dta) =>
          if err
            return callback(err, null)
          pdat = JSON.parse dta
          @Status = pdat.status
          @Done = pdat.done
          @FilePath = pdat.original
          @OutPath = pdat.converted
          return callback(null, @)


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