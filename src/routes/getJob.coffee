

module.exports = (request, response) ->
  if !request.get "Entity-ID"
    response.writeHead 400
    response.end()
  else
    eid = request.get "Entity-ID"
    @getProc eid, (err, ep) ->
      console.log err, ep
      if err
        response.writeHead 404
        response.end()
      else
        if ep.Done
          response.writeHead 200
          response.end()
        else
          response.writeHead 204
          response.end()