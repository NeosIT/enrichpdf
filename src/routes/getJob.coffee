fs = require "fs"


acceptPdf = (req) ->
  acc = req.get "Accept"
  if acc && acc.indexOf("application/pdf") > -1
    return true
  return false



module.exports = (request, response) ->
  jid = @getIdFromPath.exec request.path

  # If Job ID is given, look for it. Otherwise
  if jid
    jobId = jid[1]
    @getProc jobId, (err, ep) ->
      if err
        response.writeHead 404
        response.end()
      else
        if ep.Done && acceptPdf(request)
          response.set "Content-Type", "application/pdf"
          fstr = fs.createReadStream(ep.OutPath)
          fstr.pipe(response)
        else
          response.set "Content-Type", "application/json"
          response.end(ep.serialize())
  else
    response.writeHead 404
    response.end()