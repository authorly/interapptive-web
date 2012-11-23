# Manages the list of keyframes (from the current scene).
# Also manages the current keyframe selection and populates the WidgetLayer
# accordingly.
class App.Views.KeyframeIndex extends Backbone.View
  template:  JST["app/templates/keyframes/index"]
  tagName:   'ul'
  className: 'keyframe-list'

  events:
    'click span a.delete-keyframe': 'destroyKeyframe'
    'click  .keyframe-list li div': 'keyframeClicked'

  initialize: ->
    @collection.on('reset', @render, @)
    @collection.on('add', @appendKeyframe)
    @collection.on('change:widgets', @updateKeyframePreview, @)
    @collection.on('change:preview', @keyframePreviewChanged, @)
    @collection.on('change:positions', @render, @)


  render: ->
    $(@el).html('')

    if @collection.length > 0
      @collection.each (keyframe) => @renderKeyframe(keyframe)
      @numberKeyframes()
      @setActiveKeyframe()

    @initSortable() if @collection?

    @


  appendKeyframe: (keyframe, _collection, options) =>
    @renderKeyframe(keyframe, options.index)

    @numberKeyframes()
    @setActiveKeyframe(keyframe)


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


  destroyKeyframe: (event) =>
    event.stopPropagation()
    message  = '\nYou are about to delete a keyframe.\n\n\nAre you sure you want to continue?\n'
    target   = $(event.currentTarget)
    keyframe = @collection.get(target.attr('data-id'))

    if confirm(message)
      keyframe.destroy
        success: =>
          @collection.remove(keyframe)
          $('.keyframe-list li.active').remove()
          @numberKeyframes()
          @setActiveKeyframe()


  # setBackgroundPosition: (x, y) ->
    # $(@el).find('.active div').attr("data-x","#{x}").attr("data-y","#{y}")

    # if App.currentKeyframe()?
      # App.currentKeyframe().set
        # background_x_coord: x
        # background_y_coord: y
        # id: @activeId
      # App.currentKeyframe().save {},
        # success: (model, response) ->


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
      update: @numberKeyframes
      items: 'li[data-is_animation!="1"]'


  numberKeyframes: =>
    @$('li').each (index, element) =>
      element = $(element)

      if (id = element.data('id'))? && (keyframe = @collection.get(id))?
        # model
        keyframe.set position: index

        # and view. Would be better to listen on model changes and rerender
        e = $('span.keyframe-number', element)
        e.empty().html(index+1)


    # Backbone bug - without timeout the model is added twice
    window.setTimeout ( =>
      @collection.sort silent: true
      @collection.savePositions()
    ), 0
