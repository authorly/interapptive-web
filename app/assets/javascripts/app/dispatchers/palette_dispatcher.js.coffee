# This dispatcher serves as an intermediate for shared operations amongst
# palettes.

class PaletteDispatcher

  constructor: ->
    _.extend(@, Backbone.Events)

    @on('keyframe:change', @switchKeyframe)

  switchKeyframe: (widgetsToAdd) =>
    App.activeSpritesList.removeAll()
    @addNewWidgets(widgetsToAdd) if widgetsToAdd?

    App.spriteForm.resetForm()

  addNewWidgets: (widgetsToAdd) =>
    for widget in widgetsToAdd
      App.activeSpritesList.addSpriteToList widget unless App.activeSpritesList.hasWidget(widget)

App.Dispatchers.PaletteDispatcher = new PaletteDispatcher()
