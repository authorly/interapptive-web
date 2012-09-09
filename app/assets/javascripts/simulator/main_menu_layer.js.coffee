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
    @page.menuItems.forEach (menuItemInfo) =>
      if typeof this[menuItemInfo.storyMode] is "function"
        menuItem = new cc.MenuItemImage
        menuItem.initFromNormalImage(
          "/resources/#{menuItemInfo.normalStateImage}"
          "/resources/#{menuItemInfo.tappedStateImage}"
          false
          this
          menuItemInfo.storyMode
        )
      else
        menuItem = new cc.MenuItemImage
        menuItem.initFromNormalImage(
          "/resources/#{menuItemInfo.normalStateImage}"
          "/resources/#{menuItemInfo.tappedStateImage}"
          false
        )

      menuItem.setPosition(menuItemInfo.position)
      items.push(menuItem)

    menu = @menuItemInfoMenu = new cc.Menu
    menu.initWithItems(items)

    menu.setPosition(new cc.Point(0, 0))

    @addChild(menu, 100)

  autoPlay: =>
    @storyMode = Sim.kStoryModeAutoPlay

  readItMyself: =>
    @storyMode = Sim.kStoryModeReadItMyself
    @storybook.showPage(1)

  readToMe: =>
    @storyMode = Sim.kStoryModeReadToMe
    @storybook.showPage(1)
