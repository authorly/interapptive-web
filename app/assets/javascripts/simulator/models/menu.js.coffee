class Sim.Models.Menu extends Sim.Models.Base

  @createFromJson: (json) ->
    menu = new Sim.Models.Menu
      sprites: _.map json.CCSprites, (spriteJson) ->
        Sim.Models.Sprite.createFromJson(spriteJson)

      items: _.map json.MenuItems, (itemJson) ->
        Sim.Models.MenuItem.createFromJson(itemJson)

      sounds: {}


    if json?.sounds?.effectOnEnter?
      menu.on_enter = json.sounds.effectOnEnter
    if json?.sounds?.background?
      menu.background = _.clone json.sounds.background

    menu
