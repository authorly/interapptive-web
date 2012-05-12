class App.Views.SceneIndex extends Backbone.View
  template: JST["app/templates/scenes/index"]
  tagName: 'ul'
  className: 'scene-list'  
  events:
    'click .scene-list li span': 'clickScene'
    
  initialize: ->
    # Ensure our collection is rendered upon loading
    @collection.on('reset', @render, this)
    @collection.on('add', @appendScene, this)
    
  render: =>
    @collection.each (scene) => @appendScene(scene)

    # TODO: Figure out how to just use setActiveScene() to set the stylings
    $('.scene-list li:first span:first').click()
    return this

  createScene: =>
    scene = new App.Models.Scene
    scene.save storybook_id: App.currentStorybook().get('id'),
      wait: true
      success: (scene, response) ->
        @collection.add scene
        App.currentScene(scene)
        this.setActiveScene scene

    return scene

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

  setActiveScene: (scene) ->
    App.currentScene scene
    
    # Prepare and render correlating keyframe list for clicked scene
    keyframesCollection = new App.Collections.KeyframesCollection [],
                                 scene_id: scene.get "id"
    keyframesCollection.fetch()
    App.keyframeList new App.Views.KeyframeIndex(collection: keyframesCollection)
    $('#keyframe-list').html("")
    $('#keyframe-list').html(App.keyframeList().render().el)
    $('nav.toolbar ul li ul li').removeClass('disabled')

  clickScene: (event) ->
    $(event.currentTarget).parent().siblings().removeClass("active")
    $(event.currentTarget).parent().removeClass("active")
    $(event.currentTarget).parent().addClass("active")

    # Get out scene ID data attribute (this is the actual DB-ID)
    scene = @collection.get $(event.currentTarget).data("id")
    this.setActiveScene scene
