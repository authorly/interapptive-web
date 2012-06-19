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
    sprite    = cc.Director.sharedDirector().getRunningScene().backgroundSprite
    @activeId = $(event.currentTarget).data("id")
    @keyframe = @collection.get(@activeId)
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
