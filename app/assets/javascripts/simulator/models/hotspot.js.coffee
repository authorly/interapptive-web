class Sim.Models.Hotspot extends Sim.Models.Base

  @createFromJson: (json) ->
    new Sim.Models.Hotspot
      position: new cc.Point(json.position[0], json.position[1])
      radius: json.radius
      glitter: json.glitterIndicator
      soundUrl: json.soundToPlay


  contains: (point) ->
    dx = (point.x - @position.x)
    dy = (point.y - @position.y)
    dx * dx + dy * dy <= @radius * @radius
