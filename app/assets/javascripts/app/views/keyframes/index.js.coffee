class App.Views.KeyframeIndex extends Backbone.View
  template:  JST["app/templates/keyframes/index"]
  tagName:   'ul'
  className: 'keyframe-list'

  events:
    'click span a.delete-keyframe': 'destroyKeyframe'
    'click  .keyframe-list li div': 'setActiveKeyframe'

  initialize: ->
    @collection.on('reset', @render, this)

  render: ->
    $(@el).html('')
    @collection.each (keyframe) => @appendKeyframe(keyframe)
    @delegateEvents()
    @initSortable() if @collection?

    # Fire asynchronously so other 'reset' events can finish first
    setTimeout((=> $(@el).find('li:first div:first').click()), 1)
    this

  createKeyframe: =>
    keyframe = new App.Models.Keyframe
    keyframe.save scene_id: App.currentScene().get('id'),
      wait: true
      success: (model, response) =>
        @appendKeyframe(model)

  appendKeyframe: (keyframe) ->
    view  = new App.Views.Keyframe(model: keyframe)

    $(@el).append(view.render().el).removeClass('active').first().addClass('active')

    $('.keyframe-list li:first div').click()

    if keyframe.has "image_id"
      image = App.imageList().collection.get(keyframe.get('image_id'))

      if image? and image.has("url")
        keyfrEl = $(@el).find("[data-image-id='#{keyframe.get("image_id")}']")
        keyfrEl.css("background-image", "url(#{image.get("url")})")
        keyfrEl.attr("data-x","#{keyframe.get("background_x_coord")}")
        keyfrEl.attr("data-y","#{keyframe.get("background_y_coord")}")

  setActiveKeyframe: (event) ->
    @activeId = $(event.currentTarget).attr "data-id"
    @keyframe = @collection.get @activeId

    x_coord = $(event.currentTarget).attr "data-x"
    y_coord = $(event.currentTarget).attr "data-y"
    sprite  = cc.Director.sharedDirector().getRunningScene().backgroundSprite

    App.currentKeyframe @keyframe

    $(event.currentTarget).parent().removeClass("active").addClass("active").siblings().removeClass("active")

    @populateWidgets(@keyframe)

    sprite.setPosition(new cc.Point(x_coord, y_coord)) if sprite?

  destroyKeyframe: (event) =>
    event.stopPropagation()

    App.keyframeList().collection.fetch
      success: (collection, response) =>
        message  = '\nYou are about to delete a keyframe.\n\n\nAre you sure you want to continue?\n'
        target   = $(event.currentTarget)
        keyframe = collection.get(target.attr('data-id'))

        collection.remove(keyframe)

        if confirm(message)
          keyframe.destroy
            success: ->
              $('.keyframe-list li.active').remove()
              $('.keyframe-list li:first div').click()


  setBackgroundPosition: (x, y) ->
    $(@el).find('.active div').attr("data-x","#{x}").attr("data-y","#{y}")

    if App.currentKeyframe()?
      App.currentKeyframe().set
        background_x_coord: x
        background_y_coord: y
        id: @activeId
      App.currentKeyframe().save {},
        success: (model, response) ->
          console.log "Saved background location"

  setThumbnail: (el) ->
    oCanvas = document.getElementById "builder-canvas"
    imageId = $(@el).find('.active div').attr "data-image-id"

    try
      image = Canvas2Image.saveAsPNG oCanvas, true, 112, 84
    catch e
      alert("Problem saving scene preview image", e)
      return

    $.ajax
      url: '/storybooks/#{App.currentStorybook().get("id")}/images.json'
      type: 'POST'
      data: '{"base64":"true","image" : {"files" : [ "' + image.src.replace('data:image/png;base64,', '') + '" ] }}'
      contentType: 'application/json; charset=utf-8'
      dataType: 'json'
      success: (model, response) =>
        thumbnail = model[0]
        $(@el).find('.active div').attr "data-image-id", thumbnail.id
        $(@el).find('.active div').attr "style", "background-image: url(#{thumbnail.url})"
        @setThumbnailId thumbnail.id

  setThumbnailId: (id) =>
    App.currentScene().set
      preview_image_id:  id
      id: App.currentScene().get('id')
    App.currentScene().save {},
      wait: true
      success: ->
        console.log "Set the id of scene thumbnail"
    App.currentKeyframe().set
      image_id: id
      id: @activeId
    App.currentKeyframe().save {},
      wait: true
      success: ->
        console.log "Set the id of keyframe thumbnail"

  placeText: ->
    console.log "KeyframeIndex placeText"
    if App.currentKeyframe()?
      scene = cc.Director.sharedDirector().getRunningScene()
      keyframeTexts = scene.widgetLayer.widgets
      console.log keyframTexts
      App.builder.widgetLayer.removeAllChildrenWithCleanup()
      App.keyframesTextCollection.fetch
        success: (collection, response) =>


  populateWidgets: (keyframe) ->
    console.log "KeyframeIndex populateWidgets"
    return unless keyframe?

    App.builder.widgetLayer.clearWidgets()

    # clear text
    App.updateKeyframeText()

    if keyframe.has('widgets')
      for widgetHash in keyframe.get('widgets')
        #HACK to ignore TextWidgets in widgets hash because this is in html now
        if widgetHash.type != "TextWidget"
          klass = App.Builder.Widgets[widgetHash.type]
          throw new Error("Unable to find widget class #{klass}") unless klass
          widget = klass.newFromHash(widgetHash)
          App.builder.widgetLayer.addWidget(widget)
          widget.on('change', keyframe.updateWidget.bind(keyframe, widget))

  initSortable: =>
    $(@el).sortable
      opacity: 0.6
      containment: 'footer'
      cancel: ''
      update: =>
        $.ajax
          contentType:"application/json"
          dataType: 'json'
          type: 'POST'
          data: JSON.stringify(@keyframePositionsJSONArray())
          url: "#{@collection.ordinalUpdateUrl(App.currentScene().get('id'))}"
          complete: =>
            $(@el).sortable('refresh')

  keyframePositionsJSONArray: ->
    JSON = {}
    JSON.keyframes = []

    # Don't use cached element @el! C.W.
    $('.keyframe-list li div').each (index, element) ->
      JSON.keyframes.push
        id: $(element).data 'id'
        position: index+1

    JSON