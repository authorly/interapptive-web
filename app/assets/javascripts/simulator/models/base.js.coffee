class Sim.Models.Base

  constructor: (attributes) ->
    for key, value of attributes
      @[key] = value
