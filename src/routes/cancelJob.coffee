

module.exports = (request, response) ->
  jid = @getIdFromPath.exec request.path

  if jid
    jid = jid[1]
    @getProc jid, (err, ep) ->
      if err
        response.writeHead 404
        response.end()
      else
        if !ep.Done
          ep.cancel()
        response.writeHead 200
        response.end()
  else
    response.writeHead 404
    response.end()