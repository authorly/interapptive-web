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
    $('.keyframe-list li:first div:first').click()
    @delegateEvents()
    this

  createKeyframe: =>
    keyframe = new App.Models.Keyframe
    keyframe.save scene_id: App.currentScene().get('id'),
      wait: true
      success: (keyframe, response) =>
        @appendKeyframe(keyframe)

  appendKeyframe: (keyframe) ->
    view = new App.Views.Keyframe(model: keyframe)
    $('.keyframe-list').append(view.render().el)
    $('.keyframe-list li').removeClass('active').first().addClass('active')

  setActiveKeyframe: (event) ->
    @activeId = $(event.currentTarget).data("id")
    @keyframe = @collection.get(@activeId)
    sprite    = cc.Director.sharedDirector().getRunningScene().backgroundSprite
    if @keyframe? and sprite?
      sprite.setPosition(cc.ccp(@keyframe.get('background_x_coord'), @keyframe.get('background_y_coord')))
    $(event.currentTarget).parent().removeClass("active").addClass("active").siblings().removeClass("active")
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
    image   = Canvas2Image.saveAsPNG(oCanvas, true, 100, 100)
    $(".keyframe-list").find("[data-id='" + App.currentKeyframe().get('id') + "']").html(image)
    $.ajax
      type: "POST"
      url: "/images"
      data: '{"base64":true,"image" : {"files" : [ "' + image.src.replace('data:image/png;base64,', '') + '" ] }}'
      contentType: "application/json; charset=utf-8"
      dataType: "json"
      success: (msg) ->
        console.log "Canvas has been rendered and successfully sent to the server"
