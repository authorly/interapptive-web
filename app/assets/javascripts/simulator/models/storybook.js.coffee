class Sim.Models.Storybook extends Sim.Models.Base

  @createFromJson: (json) ->
    new Sim.Models.Storybook
      homeMenu: Sim.Models.MenuItem.createFromJson(json.Configurations.homeMenuForPages)
      menu: Sim.Models.Menu.createFromJson(json.MainMenu)
      scenes: _.map json.Pages, (pageJson) ->
        Sim.Models.Scene.createFromJson(pageJson)


  getScene: (number) ->
    _.find @scenes, (scene) => scene.number == number
