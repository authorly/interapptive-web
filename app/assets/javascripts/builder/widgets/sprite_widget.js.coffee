#= require ./widget

class App.Builder.Widgets.SpriteWidget extends App.Builder.Widgets.Widget

  constructor: (options={}) ->
    super

    @_url = options.url

    @sprite = new cc.Sprite
    @sprite.initWithFile(@_url)

    @addChild(@sprite)
    @setContentSize(@sprite.getContentSize())

  toHash: ->
    hash = super
    hash.url = @_url

    hash
