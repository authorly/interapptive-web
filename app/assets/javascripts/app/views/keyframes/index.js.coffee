class App.Views.KeyframeIndex extends Backbone.View
  template: JST["app/templates/keyframes/index"]
  tagName: 'ul'
  className: 'keyframe-list'
  events:
    'click li': 'setActiveKeyframe'
    
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
    target    = $(event.currentTarget)
    @activeId = target.data("id")
    @keyframe = @collection.get(@activeId)
    sprite    = cc.Director.sharedDirector().getRunningScene().backgroundSprite
    console.log @keyframe.get('background_x_coord') + ", " +  @keyframe.get('background_y_coord') if @keyframe?
    #if App.currentKeyframe()? and sprite?
    #  @setBackgroundPosition @keyframe.get('background_x_coord'), @keyframe.get('background_y_coord')
    target.parent().removeClass("active").addClass("active").siblings().removeClass("active")
    App.currentKeyframe(@keyframe)

  setBackgroundPosition: (x, y) ->
    App.currentKeyframe().set
      background_x_coord: x
      background_y_coord: y
      id: @activeId
    App.currentKeyframe().save {},
      success: ->
        console.log "Saved background location"
