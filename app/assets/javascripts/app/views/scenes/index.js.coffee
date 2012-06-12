class App.Views.SceneIndex extends Backbone.View
  template: JST["app/templates/scenes/index"]
  tagName: 'ul'
  className: 'scene-list'
  events:
    'click .scene-list li span': 'clickScene'
    
  initialize: ->
    @collection.on('reset', @render, this)
    @collection.on('add', @appendScene, this)

  render: =>
    $(this.el).html('')
    @collection.each (scene) => @appendScene(scene)
    $('.scene-list li:first span:first').click()
    this

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

  setActiveScene: (scene) ->
    App.currentScene scene
    App.keyframeList().collection.scene_id = scene.get "id"
    App.keyframeList().collection.fetch()
    $('#keyframe-list').html ""
    $('#keyframe-list').html(App.keyframeList().el)
    $('nav.toolbar ul li ul li').removeClass "disabled"

  clickScene: (event) ->
    sceneEl = $(event.currentTarget).parent()
    sceneEl.siblings().removeClass "active"
    sceneEl.removeClass "active"
    sceneEl.addClass "active"
    this.setActiveScene @collection.get($(event.currentTarget).data("id"))
