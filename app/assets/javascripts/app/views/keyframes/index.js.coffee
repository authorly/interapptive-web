class App.Views.KeyframeIndex extends Backbone.View
  template: JST["app/templates/keyframes/index"]
  tagName: 'ul'
  className: 'keyframe-list'
  events:
    'click .keyframe-list li div': 'setActiveKeyframe'

  initialize: ->
    @collection.on('reset', @render, this)
    $('footer').hide()

  render: ->
    $(@el).html('')
    @collection.each (keyframe) => @appendKeyframe(keyframe)
    $(@el).find('li:first div:first').click()
    @delegateEvents()
    this

  createKeyframe: =>
    keyframe = new App.Models.Keyframe
    keyframe.save scene_id: App.currentScene().get('id'),
      wait: true
      success: (model, response) =>
        @appendKeyframe(model)
    App.keyframesCollection.add(keyframe)

  appendKeyframe: (keyframe) ->
    view  = new App.Views.Keyframe(model: keyframe)
    $(@el).append(view.render().el).removeClass('active').first().addClass('active')
    if keyframe.has "image_id"
      image    = App.imageList().collection.get(keyframe.get('image_id'))
      if image? and image.has("url")
        imageUrl = image.get("url")
        imageId  = keyframe.get("image_id")
        x_coord  = keyframe.get("background_x_coord")
        y_coord  = keyframe.get("background_y_coord")
        activeKeyframeEl = $(@el).find("[data-image-id='#{imageId}']")
        activeKeyframeEl.css("background-image", "url(" + imageUrl + ")")
        activeKeyframeEl.attr("data-x","#{x_coord}")
        activeKeyframeEl.attr("data-y","#{y_coord}")

  setActiveKeyframe: (e) ->
    @placeText()
    x_coord   = $(e.currentTarget).attr "data-x"
    y_coord   = $(e.currentTarget).attr "data-y"
    @activeId = $(e.currentTarget).attr "data-id"
    @keyframe = @collection.get @activeId
    App.currentKeyframe @keyframe
    sprite = cc.Director.sharedDirector().getRunningScene().backgroundSprite
    $(e.currentTarget).parent().removeClass("active").addClass("active").siblings().removeClass("active")
    if sprite? then sprite.setPosition(new cc.Point(x_coord, y_coord))

  setBackgroundPosition: (x, y) ->
    activeKeyframeEl = $(@el).find('.active div')
    activeKeyframeEl.attr("data-x","#{x}")
    activeKeyframeEl.attr("data-y","#{y}")
    App.currentKeyframe().set
      background_x_coord: x
      background_y_coord: y
      id: @activeId
    App.currentKeyframe().save {},
      success: (model, response) ->
        console.log "Saved background location"

  setThumbnail: (el) ->
    oCanvas = document.getElementById "builder-canvas"
    image   = Canvas2Image.saveAsPNG oCanvas, true, 112, 84
    imageId = $(@el).find('.active div').attr "data-image-id"
    $.ajax
      url: '/images'
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
      preview_image_id: id
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
    if App.currentKeyframe()?

      scene = cc.Director.sharedDirector().getRunningScene()
      collection = new App.Collections.KeyframeTextsCollection(keyframe_id: App.currentKeyframe().get('id'))
      collection.fetch
        success: (collection, response) =>
          console.log collection
          for keyframeText in collection.models
            console.log "keyframe text: #{keyframeText.get('content')}"
            dice = Math.floor(Math.random() * 6) + 1
            text = new App.Builder.Widgets.TextWidget(string: "SomeSoemSoem heLLo")
            text.setPosition(new cc.Point(100*dice, 100*dice))
            text = new App.Builder.Widgets.TextWidget(string: keyframeText.get('content'))
            text.setPosition(new cc.Point(100*dice, 100*dice))
            console.log "----"
            console.log App.Builder.Widgets
            console.log "----"
            App.builder.widgetLayer.addWidget(text)
            #if @scene.getChildren()[1] then @scene.getChildren()[1].addChild(text)


    # Iterate through labels
    # if scene.getChildren()[1]
    #console.log "---------"
    #for textWidget in scene.getChildren()[1].getChildren()
    #console.log textWidget._string
    #
    # ADD
    #
    # textWidget.removeFromParentAndCleanup()
    #console.log "---------"

    # # # # # # # # # # # # # # # # # # # # # # # # # # # #
    #                                                     #
    # End add/iterate/remove text                         #
    #                                                     #
    # # # # # # # # # # # # # # # # # # # # # # # # # # # #