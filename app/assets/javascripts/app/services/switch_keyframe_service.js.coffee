class App.Services.SwitchKeyframeService

  constructor: (@oldKeyframe, @newKeyframe) ->
    @paletteDispatcher = App.Dispatchers.PaletteDispatcher
    @currentScene = App.currentScene()


  # Dispatches the service.
  execute: =>
    return if @oldKeyframe is @newKeyframe

    App.currentKeyframe(@newKeyframe)
    if App.fontToolbar? then App.fontToolbar.onCloseClick()
    @switchActiveKeyframeElement(@newKeyframe)

    #@paletteDispatcher.trigger('keyframe:change')
    @updateKeyframeWidgets()
    @updateSceneWidgets()
    @updateTextWidgets()


  switchActiveKeyframeElement: (keyframe) =>
    App.keyframeList().switchActiveKeyframe(@newKeyframe)


  updateKeyframeWidgets: =>
    if (removals = @oldKeyframe?.widgets())?
      # TODO: Kill rejection? This is legacy and a bit strange
      removals = _.reject(removals, (w) -> w.type is "TextWidget")
      @removeWidget(widget) for widget in removals

    if (additions = @newKeyframe.widgets())?
      @addWidget(widget, @newKeyframe) for widget in additions


  updateSceneWidgets: =>
    return unless (widgets = @currentScene.widgets())?
    for widget in widgets
      if App.builder.widgetLayer.hasWidget(widget) and widget.retentionMutability
        if widget.isTouchWidget()
          # Handled in widgetLayer & touchWidget
          return
        @updateWidget(widget)
      else
        @addWidget(widget, @currentScene)


  removeWidget: (widget) =>
    App.builder.widgetLayer.removeWidget(widget)
    App.activeSpritesList.removeListEntry(widget)
    App.spriteForm.resetForm()


  addWidget: (widget, owner) =>
    App.builder.widgetLayer.addWidget(widget)


  updateTextWidgets: =>
    App.updateKeyframeText()


  updateWidget: (widget) =>
    widget.setScale(widget.getScaleForKeyframe(@newKeyframe))
    widget.setPosition(widget.getPositionForKeyframe(@newKeyframe))
