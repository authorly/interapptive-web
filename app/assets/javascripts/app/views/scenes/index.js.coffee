class App.Views.SceneIndex extends Backbone.View
  template: JST["app/templates/scenes/index"]
  tagName: 'ul'
  className: 'scene-list'  
  events:
    'click .scene-list li span': 'setAsActive'
    
  setAsActive: (e) ->
    $(e.currentTarget).parent().siblings().removeClass("active")
    $(e.currentTarget).parent().removeClass("active")
    $(e.currentTarget).parent().addClass("active")
    scene_id = $(e.currentTarget).data("id")
    # Set scene that was clicked as active
    App.currentScene(@collection.get(scene_id))
    
    # Prepare and render correlating keyframe list for clicked scene
    @keyframesCollection = new App.Collections.KeyframesCollection([], {scene_id: App.currentScene().get("id")})
    @keyframesCollection.fetch()
    view = new App.Views.KeyframeIndex(collection: @keyframesCollection)
    $('#keyframe-list').html(view.render().el)
    $(".keyframe-list").overscroll()

    $('nav.toolbar ul li ul li').removeClass('disabled')
    
  initialize: ->
    # Ensure our collection is rendered upon loading
    @collection.on('reset', @render, this)
    @collection.on('add', @appendScene, this)
    
  render: ->
    @collection.each(@appendScene)
    this

  appendScene: (scene) ->
    view = new App.Views.Scene(model: scene)
    $('.scene-list').prepend(view.render().el)
