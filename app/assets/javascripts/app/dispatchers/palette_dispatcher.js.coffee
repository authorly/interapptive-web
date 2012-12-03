# This dispatcher serves as an intermediate for shared operations amongst
# palettes.

class PaletteDispatcher

  constructor: ->
    _.extend(@, Backbone.Events)

    @on('keyframe:change', @switchKeyframe)

  switchKeyframe: (widgetsToAdd) =>
    App.spriteForm.resetForm()

App.Dispatchers.PaletteDispatcher = new PaletteDispatcher()
