
module.exports = (request, response) ->
  console.log request
  response.writeHead 201, "Content-Type": "application/json"
  response.write "{}"
  response.end()

