class App.Views.KeyframeIndex extends Backbone.View
  template: JST["app/templates/keyframes/index"]
  tagName: 'ul'
  className: 'keyframe-list'
  events:
    'click .keyframe-list li div': 'setActiveKeyframe'
    
  initialize: ->
    @collection.on('reset', @render, this)
    
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

  appendKeyframe: (keyframe) ->
    view  = new App.Views.Keyframe(model: keyframe)
    $(@el).append(view.render().el).removeClass('active').first().addClass('active')
    if keyframe.has "image_id"
      image    = App.imageList().collection.get(keyframe.get('image_id'))
      imageUrl = image.get "url"
      imageId  = keyframe.get('image_id')
      activeKeyframeEl = $(@el).find("[data-image-id='#{imageId}']")
      activeKeyframeEl.css("background-image", "url(" + imageUrl + ")")

  setActiveKeyframe: (e) ->
    @activeId = $(e.currentTarget).data "id"
    @keyframe = @collection.get @activeId
    App.currentKeyframe @keyframe
    sprite = cc.Director.sharedDirector().getRunningScene().backgroundSprite
    $(e.currentTarget).parent().removeClass("active").addClass("active").siblings().removeClass("active")
    sprite.setPosition cc.ccp(@keyframe.get("background_x_coord"), @keyframe.get("background_x_coord")) if sprite?


  setBackgroundPosition: (x, y) ->
    @keyframe.set
      background_x_coord: x
      background_y_coord: y
      id: @activeId
    @keyframe.save {},
      wait: true
      success: (model, response) ->
        console.log "Saved background location"

  setThumbnail: ->
    console.log App.currentKeyframe().has "image_id"
    oCanvas = document.getElementById "builder-canvas"
    image   = Canvas2Image.saveAsPNG oCanvas, true, 112, 84
    imageId = $(@el).find('li.active div').attr "data-image-id"
    console.log "Retrived imageId: #{imageId}"
    if App.currentKeyframe().has "image_id"
      url = "/images/#{imageId}"
    else
      url = "/images"
    $.ajax
      type: "POST"
      url: url
      data: '{"base64":"true","image" : {"files" : [ "' + image.src.replace('data:image/png;base64,', '') + '" ] }}'
      contentType: "application/json; charset=utf-8"
      dataType: "json"
      beforeSend: (xhr) =>
        xhr.setRequestHeader("X-Http-Method-Override", "PUT") if @keyframe.has "image_id"
      success: (model, response) =>
        if @keyframe.has "image_id"
          thumbnail = model
        else
          thumbnail = model[0]
        $(@el).find('li.active div').attr "data-image-id", thumbnail.id
        $(@el).find('li.active div').attr "style", "background-image: url(#{thumbnail.url})"
        $(@el).find('li.active div').css "background-image", "url("  # TODO: Fixmeup


        @setThumbnailId thumbnail.id

  setThumbnailId: (id) ->
    @keyframe.set
      image_id: id
      id: @activeId
    @keyframe.save {},
      wait: true
      success: ->
        console.log "Set the id of keyframe thumbnail"