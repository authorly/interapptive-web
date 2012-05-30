#= require ./page_layer

Sim.kStoryModeAutoPlay = 1
Sim.kStoryModeReadItMyself = 2
Sim.kStoryModeReadToMe = 3

class Sim.MainMenuLayer extends Sim.PageLayer

  constructor: ->
    super

    @mainMenu.visible = false
    @createMenuItems()

  createMenuItems: ->

    items = []
    i = 0
    @page.menuItems.forEach (menuItemInfo) ->

      if typeof this[menuItemInfo.storyMode] is "function"
        menuItem = cc.MenuItemImage.itemFromNormalImage(
          "/resources/#{menuItemInfo.normalStateImage}"
          "/resources/#{menuItemInfo.tappedStateImage}"
          this
          menuItemInfo.storyMode
        )
      else
        menuItem = cc.MenuItemImage.itemFromNormalImage(
          "/resources/#{menuItemInfo.normalStateImage}"
          "/resources/#{menuItemInfo.tappedStateImage}"
        )

      menuItem.setPosition(menuItemInfo.position)
      items.push(menuItem)

    menu = @menuItemInfoMenu = new cc.Menu
    menu.initWithItems(items)

    menu.setPosition(new cc.Point(0, 0))

    @addChild(menu, 1)
