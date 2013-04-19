fs = require "fs"
path = require "path"


# Export the index route.
exports.index = (request, response) ->
  response.render "index"


# Automagically export all other routes in this directory.
fnrx = /^\w+$/
files = fs.readdirSync "./routes"
for file in files
  fn = path.basename file, ".js"
  if fnrx.test(fn) && fn!="index"
    exports[fn] = require "./" + fn