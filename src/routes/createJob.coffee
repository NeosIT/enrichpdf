path = require "path"

module.exports = (request, response) ->
  if request.files && request.files.filepdf && request.files.filepdf.type == "application/pdf"
    # @fsx.copy request.files.filepdf.path, path.join @outPath, request.files.filepdf.name
    # console.log request.files.filepdf
    console.log request.files.filepdf.fileName
    proc = @createProcess request.files.filepdf.path
    response.writeHead 201, "Content-Type": "application/json", "Entity-ID": proc.ID
    response.end()
  else
    response.writeHead 500, "Content-Type": "application/json"
    response.end()

