class Sim.Views.SpritesLayer extends cc.Layer

  constructor: (sprites)->
    super
    @sprites = sprites

    @_views = {}
    @createSprites()


  createSprites: ->
    for spriteModel in @sprites
      sprite = new Sim.Views.Sprite(spriteModel, @spriteLoaded)
      sprite.load()


  spriteLoaded: (spriteModel, texture) =>
    sprite = cc.Sprite.createWithTexture(texture)
    sprite.setVisible(false)
    @addChild sprite
    @_views[spriteModel.tag] = sprite

    @initialize()


  initialize: ->
    return unless @loaded()

    @currentActions =  {}
    for spriteModel in @sprites
      sprite = @_getSprite(spriteModel.tag)
      sprite.setPosition(spriteModel.position)
      sprite.setScale(spriteModel.scale)
      sprite.setZOrder(spriteModel.zOrder)
      sprite.setVisible(true)

      if spriteModel.action?
        @currentActions[spriteModel.tag] = spriteModel.action
        # TODO this is runactions with 'loaded'
        @animate(spriteModel.tag, spriteModel.action.action)


  loaded: ->
    _.keys(@_views).length == @sprites.length


  animate: (spriteTag, action) =>
    @_getSprite(spriteTag).runAction action


  runSwipeActions: (actions) ->
    @currentActions = actions

    for spriteTag, action of actions
      @animate spriteTag, action.action


  finishAllActions: ->
    @cleanup()
    for __, sprite of @_views
      sprite.stopAllActions()

    for spriteTag, action of @currentActions
      unless action.action.isDone()
        sprite = @_getSprite(spriteTag)
        if (position = action.finalOrientation.position)?
          sprite.setPosition(position)
        if (scale = action.finalOrientation.scale)?
          sprite.setScale(scale)

    @currentActions = {}


  _getSprite: (spriteTag) ->
      @_views[spriteTag]
