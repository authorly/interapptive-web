#= require ./sprite
class Sim.Models.MenuItem extends Sim.Models.Sprite

  @createFromJson: (json) ->
    item = Sim.Models.Sprite.createFromJson(json)
    item.url = json.normalStateImage
    item.tappedUrl = json.tappedStateImage
    item.mode = json.storyMode
    item
