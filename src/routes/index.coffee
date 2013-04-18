fs = require "fs"
path = require "path"


# Export the index route.
exports.index = (request, response) ->
  response.end "!"

# Automagically export all other routes in this directory.
fnrx = /^\w+$/
files = fs.readdirSync "./routes"
for file in files
  fn = path.basename file, ".coffee"
  if fnrx.test(fn) && fn!="index"
    exports[fn] = require "./" + fn