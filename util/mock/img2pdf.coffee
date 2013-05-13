strings = [
  "xyz",
  "123"
]

println = ->
  if strings.length > 0
    console.log strings.shift()
    setTimeout(println, Math.random() * 0.2)

println()