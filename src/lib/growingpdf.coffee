fs = require "fs"

checkEOF = (fn, callback) ->
  fd = fs.open

# Watch a pdf file until it is finished growing.
module.exports = (opts, cbf) ->
  # Check options
  if typeof opts == "string"
    opts =
      file: opts

  if typeof opts != "object" || !opts.file
    process.nextTick ->
      callback new Error "Incorrect parameters passed to growingpdf."
    return

  # Callback helper function
  callback = (err) ->
    if typeof cbf == "function"
      cbf err

  # Set defaults if necessary
  opts.timeout = opts.timeout || 300
  opts.checkstep = opts.checkstep || 0.5

  # Initialize
  checkTimeout = Date.now() + (opts.timeout * 1000)
  lastSize = 0
  fileExists = false

  checkFile = () ->
    # Check if time is up, if so callback timeout.
    if Date.now() > checkTimeout
      callback new Error "Timeout reached, growingpdf aborted."
      return

    # Check if file exists
    fs.exists opts.file, (ex) ->
      # If the file used to exist but doesn't now, it has been deleted.
      # Calback with a "deleted after creation" error.
      if fileExists && !ex
        callback new Error "File was deleted after creation."
        return

      if ex
        # If the file didn't exist before, reset the timeout.
        if !fileExists
          fileExists = true
          checkTimeout = Date.now() + (opts.timeout * 1000)

        # Check file growth and EOF
        fs.stat opts.file, (err, stats) ->
          if err
            callback err
            return
          if stats.size > lastSize
            console.log "File grown: +" + (stats.size - lastSize) + " bytes"
            lastSize = stats.size
            checkTimeout = Date.now() + (opts.timeout * 1000)

          # If file is large enough, check for EOF
          if stats.size > 10
            checkEOF opts.file, (isEOF) ->
              "do something"
          else
            setTimeout(checkFile, opts.checkstep * 1000)
            return




      else
        setTimeout(checkFile, opts.checkstep * 1000)
        return


    #if ctd >= 0
    #  setTimeout(checkFile, 1000)

  # Start
  checkFile()