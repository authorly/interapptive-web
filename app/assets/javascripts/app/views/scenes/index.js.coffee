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
        App.currentScene scene
        @setActiveScene scene
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
    $('nav.toolbar ul li ul li').removeClass 'disabled'

  setBackground: ->
    images = new App.Collections.ImagesCollection []
    scene  = App.currentScene()
    node   = cc.Director.sharedDirector().getRunningScene()
    node.removeChild node.backgroundSprite
    images.fetch success: =>
      if scene.has('image_id')
        backgroundImageId = scene.get('image_id')
        image = images.get(backgroundImageId)
        url   = image.get('url')
        cc.TextureCache.sharedTextureCache().addImage(url)
        node.backgroundSprite = cc.Sprite.spriteWithFile(url)
        node.backgroundSprite.setAnchorPoint cc.ccp(0.5, 0.5)
        node.backgroundSprite.setPosition cc.ccp(500, 300)
        node.addChild node.backgroundSprite

  setBackgroundLocation: (x, y) ->
    # App.currentKeyframe().unset('id')
    # console.log App.currentKeyframe().id
    # App.currentKeyframe().previous('id')
    App.currentKeyframe().set
      background_x_coord: x
      background_y_coord: y
    App.currentKeyframe().save id:1,
      success: (model, response) =>
        alert('saved keyframe model')

  clickScene: (event) ->
    target  = $(event.currentTarget)
    sceneId = target.data("id")
    sceneEl = target.parent()
    sceneEl.siblings().removeClass "active"
    sceneEl.removeClass "active"
    sceneEl.addClass "active"
    @setActiveScene @collection.get(sceneId)
    @setBackground()
