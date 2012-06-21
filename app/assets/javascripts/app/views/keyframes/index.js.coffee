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
    image = App.imageList().collection.get(keyframe.get('image_id'))
    $(@el).append(view.render().el).removeClass('active').first().addClass('active')
    if keyframe.has('image_id')
      $(@el).find("[data-id='" + keyframe.id + "']").css("background-image", "url(" + image.get('url') + ")")

  setActiveKeyframe: (e) ->
    @activeId = $(e.currentTarget).data("id")
    @keyframe = @collection.get(@activeId)
    sprite    = cc.Director.sharedDirector().getRunningScene().backgroundSprite
    if @keyframe? and sprite?
      sprite.setPosition(cc.ccp(@keyframe.get('background_x_coord'), @keyframe.get('background_y_coord')))
    $(e.currentTarget).parent().removeClass("active").addClass("active").siblings().removeClass("active")
    App.currentKeyframe(@keyframe)

  setBackgroundPosition: (x, y) ->
    App.currentKeyframe().set
      background_x_coord: x
      background_y_coord: y
      id: @activeId
    App.currentKeyframe().save {},
      wait: true
      success: ->
        console.log "Saved background location"

  setThumbnail: ->
    oCanvas = document.getElementById('builder-canvas')
    image   = Canvas2Image.saveAsPNG(oCanvas, true, 112, 84)
    # $(".keyframe-list").find("[data-id='" + App.currentKeyframe().get('id') + "']").html(image)
    $.ajax
      type: "POST"
      url: "/images"
      data: '{"base64":true,"image" : {"files" : [ "' + image.src.replace('data:image/png;base64,', '') + '" ] }}'
      contentType: "application/json; charset=utf-8"
      dataType: "json"
      success: (response) =>
        console.log "Canvas has been rendered and saved"
        console.log response[0]
        # Replace old image here
        # $(".keyframe-list").find("[data-id='" + App.currentKeyframe().get('id') + "']").html(image)
        @setThumbnailId(response[0].id)


  setThumbnailId: (id) ->
    App.currentKeyframe().set image_id: id
    App.currentKeyframe().save {},
      wait: true
      success: ->
        console.log "Set the id of keyframe thumbnail"