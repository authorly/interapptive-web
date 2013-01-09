# Manages the list of keyframes (from the current scene).
# Also manages the current keyframe selection and populates the WidgetLayer
# accordingly.

DELETE_KEYFRAME_MSG =
  '\nYou are about to delete a keyframe.\n\n\nAre you sure you want to continue?\n'


class App.Views.KeyframeIndex extends Backbone.View
  template:  JST['app/templates/keyframes/index']

  tagName:   'ul'

  className: 'keyframe-list'

  events:
    'click  .keyframe-list li div' : 'keyframeClicked'
    'click  .delete-keyframe'      : 'destroyKeyframeClicked'


  initialize: ->
    @collection.on 'change:positions reset add remove', @updateScenePreview    , @
    @collection.on 'change:positions reset'           , @render                , @
    @collection.on 'change:widgets'                   , @updateKeyframePreview , @
    @collection.on 'change:preview'                   , @keyframePreviewChanged, @
    @collection.on 'add'   , @appendKeyframe
    @collection.on 'remove', @removeKeyframe

    App.currentSelection.on 'change:keyframe', @keyframeChanged


  # TODO RFCTR upgrate to Backbone 0.9.9 and use `listeTo` and `stopListening`
  # instead of `on` and `off`
  remove: ->
    super

    @collection.off 'change:positions reset add remove', @updateScenePreview    , @
    @collection.off 'change:positions reset'           , @render                , @
    @collection.off 'change:widgets'                   , @updateKeyframePreview , @
    @collection.off 'change:preview'                   , @keyframePreviewChanged, @
    @collection.off 'add'   , @appendKeyframe
    @collection.off 'remove', @removeKeyframe

    App.currentSelection.off 'change:keyframe', @keyframeChanged

    App.currentSelection.on 'change:keyframe', (__, keyframe) =>
      @keyframeChanged(keyframe)

  render: ->
    @$el.empty()

    if @collection.length > 0
      @collection.each (keyframe) => @renderKeyframe(keyframe)
      @_updateDeleteButtons()
    @initSortable()

    @switchKeyframe @lastKeyframe()

    if @collection.scene.isMainMenu()
      @$el.hide()
    else
      @$el.show()

    @


  appendKeyframe: (keyframe, _collection, options) =>
    @renderKeyframe(keyframe, options.index)
    @switchKeyframe(keyframe)
    @_updateDeleteButtons()


  renderKeyframe: (keyframe, index) =>
    view = new App.Views.Keyframe(model: keyframe)
    viewElement = view.render().el

    if index == 0
      @$el.prepend viewElement
    else
      @$el.append  viewElement

    @keyframePreviewChanged(keyframe)


  keyframeClicked: (event) ->
    keyframe = @collection.get $(event.currentTarget).attr('data-id')
    @switchKeyframe(keyframe)


  switchKeyframe: (newKeyframe) =>
    App.currentSelection.set keyframe: newKeyframe


  keyframeChanged: (__, keyframe) =>
    @switchActiveKeyframeElement(keyframe)
    # @updateKeyframeWidgets(keyframe)
    # @updateSceneWidgets(keyframe)


  lastKeyframe: ->
    @collection.at(@collection.length - 1)


  # updateKeyframeWidgets: (newKeyframe) =>
    # if (removals = App.currentSelection.get('keyframe')?.widgets())?
      # # TODO: Kill rejection? This is legacy and a bit strange
      # removals = _.reject(removals, (w) -> w.type is "TextWidget")
      # for widget in removals
        # App.vent.trigger 'widget:remove', widget

    # if (additions = newKeyframe.widgets())?
      # for widget in additions
        # App.vent.trigger 'widget:add', widget


  # updateSceneWidgets: (newKeyframe) =>
    # return unless (widgets = App.currentSelection.get('scene').widgets())?

    # for widget in widgets
      # if App.builder.widgetLayer.hasWidget(widget) and widget.retentionMutability
        # return if widget.isTouchWidget()

        # widget.setScale widget.getScaleForKeyframe(newKeyframe)
        # widget.setPosition widget.getPositionForKeyframe(newKeyframe)
      # else
        # App.vent.trigger 'widget:add', widget


  switchActiveKeyframeElement: (keyframe) =>
    @$('li').removeClass('active').
      filter("[data-id=#{keyframe?.id}]").
      addClass('active')


  destroyKeyframeClicked: (event) =>
    event.stopPropagation()

    if confirm DELETE_KEYFRAME_MSG
      keyframe = @collection.get $(event.currentTarget).attr('data-id')
      keyframe.destroy
        success: =>
          @collection.remove(keyframe)


  removeKeyframe: (keyframe) =>
    $(".keyframe-list li[data-id=#{keyframe.id}]").remove()
    @switchKeyframe @lastKeyframe()
    @_updateDeleteButtons()


  updateKeyframePreview: (keyframe) ->
    return unless keyframe == App.currentKeyframe()

    canvas = document.getElementById "builder-canvas"
    image = Canvas2Image.saveAsPNG canvas, true, 110, 83

    keyframe.preview.set 'data_url', image.src


  keyframePreviewChanged: (keyframe) ->
    src = keyframe.preview.src()
    if src?
      @$("div[data-id=#{keyframe.id}]").html("<img src='#{src}'/>")


  placeText: ->
    if App.currentKeyframe()?
      scene = cc.Director.sharedDirector().getRunningScene()
      keyframeTexts = scene.widgetLayer.widgets
      App.builder.widgetLayer.removeAllChildrenWithCleanup()
      App.keyframesTextCollection.fetch
        success: (collection, response) =>

  initSortable: =>
    $(@el).sortable
      cancel      : ''
      containment : 'footer'
      items       : 'li[data-is_animation!="1"]'
      opacity     : 0.6
      update      : @_numberKeyframes


  _numberKeyframes: =>
    @$('li[data-is_animation!="1"]').each (index, element) =>
      element = $(element)

      if (id = element.data('id'))? && (keyframe = @collection.get(id))?
        keyframe.set position: index

    # Backbone bug - without timeout the model is added twice
    window.setTimeout ( =>
      @collection.sort silent: true
      @collection.savePositions()
    ), 0


  _updateDeleteButtons: =>
    show_delete = @collection.length > 1

    buttons = @$('li .delete-keyframe')
    if @collection.length > 1 then buttons.show() else buttons.hide()


  updateScenePreview: ->
    @collection.scene.setPreviewFrom @collection.at(0)
