# Manages the list of keyframes (from the current scene).
# Also manages the current keyframe selection and populates the WidgetLayer
# accordingly.
class App.Views.KeyframeIndex extends Backbone.View
  template:  JST["app/templates/keyframes/index"]
  tagName:   'ul'
  className: 'keyframe-list'

  events:
    'click span a.delete-keyframe': 'destroyKeyframeClicked'
    'click  .keyframe-list li div': 'keyframeClicked'

  initialize: ->
    @collection.on('reset', @render, @)
    @collection.on('add', @appendKeyframe)
    @collection.on('remove', @removeKeyframe)
    @collection.on('change:widgets', @updateKeyframePreview, @)
    @collection.on('change:preview', @keyframePreviewChanged, @)
    @collection.on('change:positions', @render, @)


  render: ->
    $(@el).html('')

    if @collection.length > 0
      @collection.each (keyframe) => @renderKeyframe(keyframe)
      @setActiveKeyframe()
      @_updateDeleteButtons()

    @initSortable()

    @


  appendKeyframe: (keyframe, _collection, options) =>
    @renderKeyframe(keyframe, options.index)
    @setActiveKeyframe(keyframe)

    @_updateDeleteButtons()


  renderKeyframe: (keyframe, index) =>
    view  = new App.Views.Keyframe(model: keyframe)
    viewElement = view.render().el
    if index == 0
      @$el.prepend viewElement
    else
      @$el.append  viewElement

    @keyframePreviewChanged(keyframe)


  keyframeClicked: (event) ->
    id = $(event.currentTarget).attr "data-id"
    keyframe = @collection.get id
    @setActiveKeyframe(keyframe)


  setActiveKeyframe: (keyframe) ->
    keyframe = @collection.at(@collection.length - 1) unless keyframe?

    App.currentKeyframe keyframe
    @$('li').removeClass('active').filter("[data-id=#{keyframe.id}]").addClass('active')
    @populateWidgets(keyframe)


  destroyKeyframeClicked: (event) =>
    event.stopPropagation()
    message  = '\nYou are about to delete a keyframe.\n\n\nAre you sure you want to continue?\n'
    target   = $(event.currentTarget)
    keyframe = @collection.get(target.attr('data-id'))

    if confirm(message)
      keyframe.destroy
        success: => @collection.remove(keyframe)


  removeKeyframe: (keyframe) =>
    $(".keyframe-list li[data-id=#{keyframe.id}]").remove()
    @setActiveKeyframe()
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


  populateWidgets: (keyframe) ->
    return unless keyframe?

    App.builder.widgetLayer.populateFromKeyframe(keyframe)


  initSortable: =>
    $(@el).sortable
      opacity: 0.6
      containment: 'footer'
      cancel: ''
      update: @_numberKeyframes
      items: 'li[data-is_animation!="1"]'


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
