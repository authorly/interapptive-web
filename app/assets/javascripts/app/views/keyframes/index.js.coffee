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

    App.vent.on 'scene:remove', (scene) =>
      if scene.canAddKeyframes() then @$el.empty()

    App.vent.on 'scene:active', (scene) =>
      if scene.canAddKeyframes() then @$el.show() else @$el.hide()


  render: ->
    @$el.empty()

    if @collection.length > 0
      @collection.each (keyframe) => @renderKeyframe(keyframe)
      @switchKeyframe()
      @_updateDeleteButtons()

    @delegateEvents() # needed, even though it should work without it
    @initSortable()
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


  switchKeyframe: (keyframe) =>
    #
    # RFCTR:
    #     Needs ventilation
    #
    keyframe = @collection.at(@collection.length - 1) unless keyframe?
    switcher = new App.Services.SwitchKeyframeService(App.currentKeyframe(), keyframe)
    switcher.execute()


  # TODO: Rename this to switchActiveKeyframeElement
  switchActiveKeyframe: (keyframe) =>
    @$('li').removeClass('active').
      filter("[data-id=#{keyframe.id}]").
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
    @switchKeyframe()
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
    # must go through the scenesCollection, because the relationship
    # between the scene model and its keyframes is not stored anywhere
    scene = App.scenesCollection.get(@collection.scene_id)
    scene?.setPreviewFrom @collection.at(0)
