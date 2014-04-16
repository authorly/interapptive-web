class Sim.Models.Sprite extends Sim.Models.Base

  @createFromJson: (json) ->
    new Sim.Models.Sprite
      tag: json.spriteTag
      url: json.image
      position: new cc.Point(json.position[0], json.position[1])
      scale: json.scale
      visible: json.visible || true
      zOrder: json.zOrder
