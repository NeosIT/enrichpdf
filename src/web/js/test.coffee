
@send = ->
  console.log "Submit!"
  $("#testForm").ajaxSubmit({})

@getInfo = ->
  console.log document.getElementById("reqID").value
  $.ajax
    url: "/job"
    data: ""
    beforeSend: (xhr) ->
      xhr.setRequestHeader "Entity-ID", document.getElementById("reqID").value