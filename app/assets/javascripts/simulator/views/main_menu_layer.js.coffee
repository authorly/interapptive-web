class Sim.Views.MainMenuLayer extends cc.Menu

  constructor: (items) ->
    super
    @items = items

    @createItems()


  createItems: ->
    _views = []
    for itemModel in @items
      callback = itemModel.mode
      item = cc.MenuItemImage.create(itemModel.url, itemModel.tappedUrl, callback, @)
      item.setPosition(itemModel.position)
      item.setScale(itemModel.scale)
      item.setZOrder(itemModel.zOrder)
      _views.push item

    @initWithItems _views


  autoPlay: ->
    @_setMode('autoPlay')


  readToMe: ->
    @_setMode('readToMe')


  readItMyself: ->
    @_setMode('readItMyself')


  _setMode: (mode) ->
    Sim.storybook.setMode(mode)
