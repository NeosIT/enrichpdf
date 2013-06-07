fs = require "fs"
pdf2pdf = require "pdf2pdf"
path = require "path"
growingpdf = require "./growingpdf"
fsx = require "./filehelpers"


class Enrich
  constructor: (@App, @ID, @FilePath, @OutPath) ->
    # Members
    @Status = "Init"
    @Done = false
    @Error = false
    @Continue = true
    @MailRecipients = []
    @OutPath = @OutPath || path.resolve(path.join(@App.cfg.ocr.store, @ID, "converted.pdf"))


  # Initiate conversion
  convert: ->
    @Status = "Waiting for PDF."
    @save()
    growingpdf @FilePath, (err) =>
      if err
        @Status = err.message
        @save()
        return

      # TODO: Send e-mail that process is beginning.
      # Move original PDF to proc location
      @moveSourceFile (err) =>
        if err
          @Status = err.message
          @save()
          return
        @Status = "Beginning conversion."
        @save()
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
      @App.info "Enrich process #" + @ID + " completed successfully."
      @Done = true
      @Status = "Complete."
    @save()

    # Send eMail
    if @MailRecipients.length > 0
      growingpdf @OutPath, @sendMail.bind(this)


  # Send email with attachment
  sendMail: ->
    for recip in @MailRecipients
      if /[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}/i.test recip
        @App.sendMail
          from: "enrichpdf@neos-it.de"
          to: recip
          subject: "Success e-mail baby yeah!"
          body: "This is the successfully converted PDF."
          attachment: [
            path: @OutPath
            type: "application/pdf"
            name: "converted.pdf"
          ]
        , (err) =>
          if err
            @App.log "error", err.message, if err.stack then callstack:err.stack else null


  # Callback whenever conversion process advances.
  processCallback: (stat) ->
    @App.info "Enrich process #" + @ID + " status: " + stat
    @Status = stat
    @save()
    @Continue


  # Save this entity to file.
  save: ->
    if !fs.existsSync path.join(@App.cfg.ocr.store, @ID)
      fs.mkdirSync path.join(@App.cfg.ocr.store, @ID)
    fs.writeFileSync path.join(@App.cfg.ocr.store, @ID, "meta.json"), @serialize(), encoding:"utf8", flag:"w"
    @


  # Attempt to load process data from disk
  load: (callback) ->
    @App.info "Attempting to load Enrich process #" + @ID
    if @ID && typeof callback == "function"
      fpath = path.join(@App.cfg.ocr.store, @ID, "meta.json")
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


  # Set this process to cancelled.
  cancel: ->
    @App.info "Cancelling Enrich process #" + @ID
    @Continue = false


  # Move source file to proc folder
  moveSourceFile: (callback) ->
    newPath = path.resolve(path.join(@App.cfg.ocr.store, @ID, "source.pdf"))
    fsx.mkdirp(path.dirname(newPath), 0o777)
    # Copy file
    if fs.existsSync(@FilePath) && fs.existsSync(path.dirname(newPath))
      reader = fs.createReadStream(@FilePath)
      reader.pipe(fs.createWriteStream(newPath))
      reader.on "end", (err) =>
        if fs.existsSync newPath
          fs.unlinkSync(@FilePath)
          @FilePath = newPath
          callback()
        else
          callback new Error "Something went wrong."
    else
      callback new Error("Something went wrong copying the source file.")



  # Class method, generates a unique ID for the process.
  @generateUniqueID: ->
    (Math.floor(Math.random()*100000000)).toString(36) + (+new Date()).toString(36)



module.exports = Enrich