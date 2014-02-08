#= require ./sprite_widget

class App.Builder.Widgets.ButtonWidget extends App.Builder.Widgets.SpriteWidget

  constructor: (options) ->
    super

    @model.on 'change:image_id', @refresh, @
    @model.on 'change:disabled', @_disabledChanged, @
    @_disabledChanged()


  refresh: ->
    @removeChild @sprite
    @loadImage()


  _disabledChanged: ->
    opacity = if @model.get('disabled') then 100 else 255
    @setOpacity opacity
