fs = require "fs"
path = require('path')

# Simple file copy function
copy = (srcfile, tgtfile) ->
  fs.createReadStream(srcfile).pipe(fs.createWriteStream(tgtfile || fileInfo(srcfile).copypath))
exports.copy = copy

# Recursive mkdir function
mkdirp = (dir, mode, position) ->
  mode = mode || process.umask()
  parts = path.normalize(dir).split(path.sep)
  position = position || 0

  if position >= parts.length
    return true

  directory = parts.slice(0, position + 1).join(path.sep) || path.sep
  try
    fs.statSync(directory)
    mkdirp(dir, mode, position + 1)
  catch e
    try
      fs.mkdirSync(directory, mode);
      mkdirp(dir, mode, position + 1);
    catch e
      if e.code != 'EEXIST'
        throw e
      mkdirp(dir, mode, position + 1)
exports.mkdirp = mkdirp

# Walk a directory and call a function on each element
walk = (srcdir, callback) ->
  items = fs.readdirSync(srcdir)
  mkdirp(fileInfo(srcdir).copypath)
  for item in items
    fullpath = srcdir + "/" + item
    if item != "Thumbs.db"
      if fs.statSync(fullpath).isDirectory()
        walk(fullpath, callback)
      else
        if (typeof callback == "function")
          callback(fullpath)
exports.walk = walk

# Get specific info on a source file
fileInfo = (filepath) ->
  dta = {}
  dta.relpath = path.relative("../src", path.dirname(filepath))
  dta.fileext = path.extname(filepath)
  dta.basename = path.basename(filepath, dta.fileext)
  dta.copypath = path.join("../build", dta.relpath, dta.basename + dta.fileext)
  dta.targetpath = path.join("../build", dta.relpath, dta.basename + if dta.fileext==".coffee" then ".js" else dta.fileext)
  dta.targetfullpath = path.resolve(path.join("../build", dta.relpath))
  return dta
exports.fileInfo = fileInfo

# Clear the build directory
clearDir = (dir) ->
  items = fs.readdirSync(dir)
  # Iterate over items in the directory
  for item in items
    fullpath = dir + "/" + item
    if fs.statSync(fullpath).isDirectory()
      # It's a subdirectory. Walk it, then delete.
      clearDir(fullpath)
      fs.rmdirSync(fullpath)
    else
      fs.unlinkSync(fullpath)
exports.clearDir = clearDir