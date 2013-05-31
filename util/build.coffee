# Initialize
process.chdir(__dirname)

# Require built-in libs
fs = require "fs"
path = require "path"

# 3rd party libs
coffee = require("coffee-script").compile
uglify = require("uglify-js").minify

# Require own libs
fsx = require "../src/lib/filehelpers"


# Method for compiling and minifying coffee-script files.
compile = (srcfile) ->
  fi = fsx.fileInfo(srcfile)
  if fi.fileext == ".coffee"
    fsx.mkdirp fi.targetfullpath
    fs.writeFileSync(fi.targetpath, uglify(coffee(fs.readFileSync(srcfile, "UTF-8")), (fromString: true)).code)


# Clear directory
console.log "Clearing build directory..."
fsx.mkdirp "../build"
fsx.clearDir "../build"
fsx.mkdirp "../build/logs"
fsx.mkdirp "../build/procs"

# Build the project
console.log "Building..."

compile("../src/server.coffee") # Compile main server file
fsx.walk("../src/config", fsx.copy) # Copy configs
fsx.walk("../src/views", fsx.copy) # Copy views
fsx.walk("../src/web", fsx.copy) # Copy web
fsx.walk("../src/routes", compile) # Compile routes
fsx.walk("../src/lib", compile) # Compile lib

fsx.copy("../package.json", "../build/package.json")