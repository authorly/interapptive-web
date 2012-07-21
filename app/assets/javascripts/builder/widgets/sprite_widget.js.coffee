#= require ./widget

class App.Builder.Widgets.SpriteWidget extends App.Builder.Widgets.Widget

  constructor: (options={}) ->
    super

    @_url = options.url

    @sprite = cc.Sprite.spriteWithFile(@_url)

    @addChild(@sprite)
    @setContentSize(@sprite.getContentSize())

  toHash: ->
    hash = super
    hash.url = @_url

    hash
