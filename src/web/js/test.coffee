
@send = ->
  console.log "Submit!"
  $("#testForm").ajaxSubmit (x,y,z) ->
    console.log x, y, z

@getInfo = ->
  $.ajax
    url: "/job/" + document.getElementById("reqID").value
    data: ""

@getPdf = ->
  $.ajax
    url: "/job/" + document.getElementById("reqID").value
    data: ""
    beforeSend: (xhr) ->
      xhr.setRequestHeader "Accept", "application/pdf"