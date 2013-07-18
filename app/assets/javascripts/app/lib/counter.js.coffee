class App.Lib.Counter

  constructor: ->
    @current = 13


  next: ->
    @current += 1


  check: (value) ->
    @current = value if value > @current
    value
