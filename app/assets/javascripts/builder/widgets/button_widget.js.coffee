#= require ./sprite_widget

class App.Builder.Widgets.ButtonWidget extends App.Builder.Widgets.SpriteWidget

  constructor: (options) ->
    super

    @model.on 'change:image_id', @refresh, @
    @model.on 'change:disabled', @_disabledChanged, @


  refresh: ->
    @_getImage()


  _disabledChanged: (__, disabled) ->
    @setOpacity(if disabled then 100 else 255)
