path = require "path"

module.exports = (request, response) ->
  if request.files && request.files.filepdf
    # @fsx.copy request.files.filepdf.path, path.join @outPath, request.files.filepdf.name
    console.log request.get
    response.writeHead 200, "Content-Type": "application/json"
    response.write "{}"
    response.end()
  else
    response.writeHead 500, "Content-Type": "application/json"
    response.write "{'error':true}"
    response.end()

