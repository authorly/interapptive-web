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
      imageId  = keyframe.get('image_id')
      activeKeyframeEl = $(@el).find("[data-image-id='#{imageId}']")
      imageUrl   = image.get "url"
      activeKeyframeEl.css("background-image", "url(" + imageUrl + ")")

  setActiveKeyframe: (e) ->
    @activeId = $(e.currentTarget).data "id"
    @keyframe = @collection.get @activeId
    sprite    = cc.Director.sharedDirector().getRunningScene().backgroundSprite
    $(e.currentTarget).parent().removeClass("active").addClass("active").siblings().removeClass("active")
    if @keyframe? and sprite? then sprite.setPosition cc.ccp(@keyframe.get("background_x_coord"), @keyframe.get("background_x_coord"))
    App.currentKeyframe @keyframe

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
    oCanvas = document.getElementById "builder-canvas"
    image   = Canvas2Image.saveAsPNG oCanvas, true, 112, 84
    imageId = $(@el).find('li.active div').attr "data-image-id"
    postDataForUpdate = if @keyframe.has "image_id" then "\"image_id\" : \"#{imageId}\"," else ""
    $.ajax
      type: "PUT"
      url: if @keyframe.has "image_id" then "/images/#{imageId}" else "/images"
      data: '{'+ postDataForUpdate + '"base64":true,"image" : {"files" : [ "' + image.src.replace('data:image/png;base64,', '') + '" ] }}'
      contentType: "application/json; charset=utf-8"
      dataType: "json"
      beforeSend: (xhr) ->
        xhr.setRequestHeader("X-Http-Method-Override", "PUT")
      success: (model, response) =>
        console.log "Canvas has been rendered and saved"
        activeKeyframeEl = $(@el).find("[data-image-id='#{imageId}']")
        image            = model[0]
        activeKeyframeEl.css "background-image", "url(" + image.url + ")"  # TODO: Fixmeup
        activeKeyframeEl.attr "data-image-id", image.id
        @setThumbnailId image.id

  setThumbnailId: (id) ->
    App.currentKeyframe().set image_id: id
    App.currentKeyframe().save {},
      wait: true
      success: ->
        console.log "Set the id of keyframe thumbnail"