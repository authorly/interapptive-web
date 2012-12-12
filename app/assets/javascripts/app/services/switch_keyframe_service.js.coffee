class App.Services.SwitchKeyframeService

  constructor: (@oldKeyframe, @newKeyframe) ->
    @paletteDispatcher = App.Dispatchers.PaletteDispatcher
    @currentScene = App.currentScene()

  # Dispatches the service.
  execute: =>
    return if @oldKeyframe is @newKeyframe

    App.currentKeyframe @newKeyframe
    App.fontToolbar.onCloseClick.call(App.fontToolbar)
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
    widgetsChanged = false

    for widget in widgets
      if App.builder.widgetLayer.hasWidget(widget) and widget.retentionMutability
        res = @updateWidget(widget)
        widgetsChanged = widgetsChanged || res

      else if App.builder.widgetLayer.hasWidget(widget)

      else
        @addWidget(widget, @currentScene)

    if widgetsChanged
      @currentScene.widgetsChanged()

  removeWidget: (widget) =>
    App.builder.widgetLayer.removeWidget(widget)
    App.activeSpritesList.removeListEntry(widget)
    App.spriteForm.resetForm()


  addWidget: (widget, owner) =>
    App.builder.widgetLayer.addWidget(widget)
    #widget.on('change', owner.updateWidget.bind(owner, widget))


  updateTextWidgets: =>
    App.updateKeyframeText()

  updateWidget: (widget) =>
    widget.setScale(widget.getScale(@newKeyframe))
    widget.setPosition(widget.getPosition(@newKeyframe), false)
    # QUESTION: WA:
    # Why do we update a scene's widget when we are only switching
    # between them? App.Views.KeyframeIndex.appendKeyframe might
    # be the cause we do it here. Even in that case, we should
    # move it to App.Views.ToolbarView._addKeyframe(). OR much
    # better; as a before callback to Keyframe.save()
    return App.currentScene().updateWidget(widget, true)

  # For debugging changes in keyframe. Shows a snapshot of the following info:
  # - The number of widgets in the old keyframe
  # - The number of widgets in the new keyframe
  showStats: (msg) =>
    console.group msg
    console.log "OKF", @oldKeyframe?.get('widgets')?.length, "NKF", @newKeyframe?.get('widgets')?.length
    console.groupEnd()
