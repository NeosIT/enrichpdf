path = require "path"

module.exports = (request, response) ->
  if request.files && request.files.filepdf && request.files.filepdf.type == "application/pdf"
    # console.log request.files.filepdf.fileName
    proc = @createProcess request.files.filepdf.path
    @info "Web API: Created EnrichPDF job #" + proc.ID
    response.writeHead 201, "Content-Type": "application/json", "Entity-ID": proc.ID
    response.end()
  else
    response.writeHead 500, "Content-Type": "application/json"
    response.end()

