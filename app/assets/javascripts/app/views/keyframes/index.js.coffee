class App.Views.KeyframeIndex extends Backbone.View
  template: JST["app/templates/keyframes/index"]
  tagName: 'ul'
  className: 'keyframe-list'
  events:
    'click .keyframe-list li div': 'clickKeyframe'
    
  initialize: ->
    @collection.on('reset', @render, this)
    
  render: ->
    $(@el).html('')
    @collection.each (keyframe) => @appendKeyframe(keyframe)
    $('.keyframe-list li:first div:first').click()
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
    $(".keyframe-list li").removeClass "active"
    $(".keyframe-list li").first().addClass "active"

  setActiveKeyframe: ->
    App.currentKeyframe(@keyframe)

  clickKeyframe: (event) ->
    @activeId = $(event.currentTarget).data("id")
    @keyframe = @collection.get(@activeId)
    $(event.currentTarget).parent().siblings().removeClass("active")
    $(event.currentTarget).parent().removeClass("active")
    $(event.currentTarget).parent().addClass("active")
    @setActiveKeyframe()

  setBackgroundLocation: (x, y) ->
    App.currentKeyframe().set
      background_x_coord: x
      background_y_coord: y
      id: @activeId
    App.currentKeyframe().save {},
      success: ->
        console.log "Saved background location"
