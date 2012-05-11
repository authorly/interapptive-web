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

    # Get out scene ID data attribute (this is the actual DB-ID)
    scene_id = $(e.currentTarget).data("id")

    App.currentScene(@collection.get(scene_id))
    
    # Prepare and render correlating keyframe list for clicked scene
    @keyframesCollection = new App.Collections.KeyframesCollection([], {scene_id: App.currentScene().get("id")})
    @keyframesCollection.fetch()
    view = new App.Views.KeyframeIndex(collection: @keyframesCollection)
    $('#keyframe-list').html("")
    $('#keyframe-list').html(view.render().el)
    $('nav.toolbar ul li ul li').removeClass('disabled')
    
  initialize: ->
    # Ensure our collection is rendered upon loading
    @collection.on('reset', @render, this)
    @collection.on('add', @appendScene, this)
    
  render: ->
    @collection.each(@appendScene)

    # Select the first scene automatically upon rendering.
    $(this.el).find('li:first span').click()

    return this

  appendScene: (scene) ->
    view = new App.Views.Scene(model: scene)
    $('.scene-list').append(view.render().el)
    pageNumber = scene.get('page_number')
    numberHolder = $(view.el).find('span span span')
    
    numberHolder.html pageNumber
    
    # Different styles (font-sizes, placement) for different brackets (0-9,10-19,20-29, etc.)
    if pageNumber > 9
      numberHolder.removeClass "inner-single-digit"
      numberHolder.addClass "inner"
    else
      numberHolder.removeClass "inner"
      numberHolder.addClass "inner-single-digit"
