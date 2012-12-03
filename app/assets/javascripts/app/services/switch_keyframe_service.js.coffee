class App.Services.SwitchKeyframeService

  constructor: (@oldKeyframe, @newKeyframe) ->
    @widgetLayer = App.builder.widgetLayer
    @paletteDispatcher = App.Dispatchers.PaletteDispatcher
    @currentScene = App.currentScene()

  # Dispatches the service.
  execute: =>
    return if @oldKeyframe is @newKeyframe

    App.currentKeyframe @newKeyframe
    @switchActiveKeyframeElement(@newKeyframe)

    #@paletteDispatcher.trigger('keyframe:change')
    @updateKeyframeWidgets()
    @updateSceneWidgets()
    @updateTextWidgets()



  switchActiveKeyframeElement: (keyframe) =>
    App.keyframeList().switchActiveKeyframe(@newKeyframe)


  updateKeyframeWidgets: =>
    if (removals = @oldKeyframe?.get('widgets'))?
      # TODO: Kill rejection? This is legacy and a bit strange
      removals = _.reject(removals, (w) -> w.type is "TextWidget")
      @removeWidget(widget) for widget in removals

    if (additions = @newKeyframe.get('widgets'))?
      @addWidget(@newWidgetFromOpts(widgetOpts), @newKeyframe) for widgetOpts in additions


  updateSceneWidgets: =>
    return unless (widgets = @currentScene.get('widgets'))?

    for widgetOpts in widgets
      if @widgetLayer.hasWidget(widgetOpts) and widgetOpts.retentionMutability
        widget = @loadWidgetFromOpts(widgetOpts)
        @updateWidgetKeyframeDatum(widget, @newKeyframe) unless widget.hasKeyframeDatum(@newKeyframe)
        @updateWidget(widget)

      else if @widgetLayer.hasWidget(widgetOpts)

      else
        widget = @newWidgetFromOpts(widgetOpts)
        @addWidget(widget, @currentScene)


  removeWidget: (widgetOpts) =>
    widget = @newWidgetFromOpts(widgetOpts)
    @widgetLayer.removeWidget(widget)
    App.activeSpritesList.removeListEntry(widget)
    App.spriteForm.resetForm()


  addWidget: (widget, owner) =>
    @widgetLayer.addWidget(widget)
    widget.on('change', owner.updateWidget.bind(owner, widget))


  updateTextWidgets: =>
    App.updateKeyframeText()


  updateWidgetKeyframeDatum: (widget, keyframe) =>
    keyframeCollection = App.keyframeList().collection
    widget.copyKeyframeDatum(keyframe, keyframeCollection.at(keyframeCollection.length - 2))


  updateWidget: (widget) =>
    widget.setScale(widget.getScale())
    widget.setPosition(widget.getPosition())
    App.currentScene().updateWidget(widget)

  # Constructs a new widget from a hash of options.
  newWidgetFromOpts: (opts) =>
    klass = App.Builder.Widgets[opts.type]
    throw new Error("Unable to find widget class #{klass}") unless klass
    klass.newFromHash(opts)

  loadWidgetFromOpts: (opts) =>
    @widgetLayer.widgetAtId(opts.id)

  # For debugging changes in keyframe. Shows a snapshot of the following info:
  # - The number of widgets in the old keyframe
  # - The number of widgets in the new keyframe
  showStats: (msg) =>
    console.group msg
    console.log "OKF", @oldKeyframe?.get('widgets')?.length, "NKF", @newKeyframe?.get('widgets')?.length
    console.groupEnd()
