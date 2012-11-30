class App.Services.SwitchKeyframeService
  widgetsToAdd:       []
  widgetsToRemove:    []
  widgetsToKeep:      []

  constructor: (@oldKeyframe, @newKeyframe) ->
    @widgetLayer = App.builder.widgetLayer
    @paletteDispatcher = App.Dispatchers.PaletteDispatcher

  # Dispatches the service.
  execute: =>
    # Don't do nothin' if we're clicking on the same keyframe.
    return if @oldKeyframe is @newKeyframe

    # Update the tracked currently active keyframe.
    # This needs to happen early because positioning in touch widgets requires 
    # the current keyframe.
    App.currentKeyframe @newKeyframe

    @widgetLayer.clearWidgets()
    @copyWidgets()
    @doAddition()

    @paletteDispatcher.trigger('keyframe:change', @widgetsToAdd)

    # Because keyframe texts are a bit peculiar
    App.updateKeyframeText()

    # Switch keyframes
    App.keyframeList().switchActiveKeyframe(@newKeyframe)

  # Performs all operations needed to add the widgets that belong to this 
  # keyframe.
  doAddition: =>
    # TODO: Kill rejection? Why is this here?
    @widgetsToAdd = _.reject(@newKeyframe.get('widgets'), (w) -> w.type is "TextWidget")
    @widgetsToAdd = _.map(@widgetsToAdd, (widgetOpts) => @newWidgetFromOpts(widgetOpts))

    for widget in @widgetsToAdd
      # Add widget to layer if it doesn't exist there. For new widgets.
      unless @widgetLayer.hasWidget(widget)
        @widgetLayer.addWidget(widget, true)
        widget.on('change', @newKeyframe.updateWidget.bind(@newKeyframe, widget))

  # This copies widgets from the last keyframe to the new keyframe if necessary.
  copyWidgets: =>
    keyframeCollection = App.keyframeList().collection

    # If there's more than one keyframe (i.e. we're creating one manually)
    if keyframeCollection?.length > 1
      copySource = keyframeCollection.at(keyframeCollection.length - 2)

      # If there are widgets in the copysource and not the new keyframe
      if (widgets = copySource.get('widgets'))? and !@newKeyframe.get('widgets')
        for widgetOpts in widgets
          # Instantiate widget so it gets added to new keyframes if it has a
          # scene-based retention hookup
          widget = @newWidgetFromOpts(widgetOpts)

          # If it's keyframe-independent, copy an independence hash to it
          if widgetOpts.retentionMutability
            widget.copyKeyframe(@newKeyframe, copySource) 

  # Constructs a new widget from a hash of options.
  newWidgetFromOpts: (opts) =>
    klass = App.Builder.Widgets[opts.type]
    throw new Error("Unable to find widget class #{klass}") unless klass
    klass.newFromHash(opts)

  # For debugging changes in keyframe. Shows a snapshot of the following info:
  # - How many widgets are added (including ones kept from the old keyframe)
  # - Those kept from the old keyframe
  # - Those removed in the transition
  # - The number of widgets in the old keyframe
  # - The number of widgets in the new keyframe
  showStats: (msg) =>
    console.group msg
    console.log "Add", @widgetsToAdd.length, "Keep", @widgetsToKeep.length, "Remove", @widgetsToRemove.length
    console.log "OKF", @oldKeyframe?.get('widgets')?.length, "NKF", @newKeyframe?.get('widgets')?.length
    console.groupEnd()
