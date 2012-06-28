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

    App.keyframesCollection.add(keyframe)

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
    if sprite?
      sprite.setPosition(new cc.Point(App.currentKeyframe().get("background_x_coord"), App.currentKeyframe().get("background_y_coord")))


  setBackgroundPosition: (x, y) ->
    console.log "x, y   (#{x}, #{y})"
    @keyframe.set
      background_x_coord: x
      background_y_coord: y
      id: @activeId
    @keyframe.save {},
      success: (model, response) ->
        console.log "Saved background location"

  setThumbnail: ->
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
        # console.log "Array!" if Object::toString.call(model) is "[object Array]"
        thumbnail = model[0]
        $(@el).find('li.active div').attr "data-image-id", thumbnail.id
        $(@el).find('li.active div').attr "style", "background-image: url(#{thumbnail.url})"
        @setThumbnailId thumbnail.id

  setThumbnailId: (id) =>
    @keyframe.set
      image_id: id
      id: @activeId
    @keyframe.save {},
      wait: true
      success: ->
        console.log "Set the id of keyframe thumbnail"
