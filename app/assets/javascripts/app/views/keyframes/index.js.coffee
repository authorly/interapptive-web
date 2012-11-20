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


  render: ->
    $(@el).html('')
    @collection.each (keyframe) => @appendKeyframe(keyframe)
    @delegateEvents()
    @initSortable() if @collection?

    # Fire asynchronously so other 'reset' events can finish first
    # setTimeout((=> $(@el).find('li:last-child div:last').click()), 1)
    this

  createKeyframe: =>
    keyframe = new App.Models.Keyframe
      scene_id: App.currentScene().get('id')
    keyframe.save {},
      wait: true
      success: (model, response) =>
        @collection.add keyframe


  appendKeyframe: (keyframe) =>
    view  = new App.Views.Keyframe(model: keyframe)
    $(@el).append(view.render().el)

    @numberKeyframes()
    @setActiveKeyframe(keyframe)

    @keyframePreviewChanged(keyframe)


  keyframeClicked: (event) ->
    id = $(event.currentTarget).attr "data-id"
    keyframe = @collection.get id
    @setActiveKeyframe(keyframe)


  setActiveKeyframe: (keyframe) ->
    App.currentKeyframe keyframe
    # TODO data-id should be on the top-most element (`li`), not on the
    # inner element (`div`) to work easier with selectors
    @$('li').removeClass('active').find("[data-id=#{keyframe.id}]").parent().addClass('active')
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
          $('.keyframe-list li:last div').click()


  setBackgroundPosition: (x, y) ->
    $(@el).find('.active div').attr("data-x","#{x}").attr("data-y","#{y}")

    if App.currentKeyframe()?
      App.currentKeyframe().set
        background_x_coord: x
        background_y_coord: y
        id: @activeId
      App.currentKeyframe().save {},
        success: (model, response) ->


  updateKeyframePreview: (keyframe) ->
    return unless keyframe == App.currentKeyframe()

    canvas = document.getElementById "builder-canvas"
    image = Canvas2Image.saveAsPNG canvas, true, 110, 83

    keyframe.preview.set 'data_url', image.src


  keyframePreviewChanged: (keyframe) ->
    src = keyframe.preview.src()
    if src?
      @$("[data-id=#{keyframe.id}]").html("<img src='#{src}'/>")


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
    @numberKeyframes()

    $(@el).sortable
      opacity: 0.6
      containment: 'footer'
      cancel: ''
      update: =>
        @numberKeyframes()
        $.ajax
          contentType:"application/json"
          dataType: 'json'
          type: 'POST'
          data: JSON.stringify(@keyframePositionsJSONArray())
          url: "#{@collection.ordinalUpdateUrl(App.currentScene().get('id'))}"
          success: =>
            @collection.sort()
          complete: =>
            $(@el).sortable('refresh')

  keyframePositionsJSONArray: ->
    JSON = {}
    JSON.keyframes = []

    $('.keyframe-list li div').each (index, element) ->
      JSON.keyframes.push
        id: $(element).data 'id'
        position: index+1

    JSON

  numberKeyframes: ->
    $('.keyframe-list li div').each (index, element) =>
      element = $(element)

      e = $('span.keyframe-number', element)
      e.empty().html(index+1)

      if (id = element.data('id'))?
        @collection.get(id).set position: index
