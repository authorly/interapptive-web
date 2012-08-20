class App.Views.SceneIndex extends Backbone.View
  template: JST["app/templates/scenes/index"]
  tagName: 'ul'
  className: 'scene-list'
  events:
    'click .scene-list li span': 'clickScene'
    
  initialize: ->
    @collection.on('reset', @render, this)
    @collection.on('add', @appendScene, this)
    $(".sidebar").hide()
    $("header").hide()

  render: =>
    $(this.el).html('')
    @collection.each (scene) => @appendScene(scene)
    $('.scene-list li:first span:first').click()
    App.toggleHeader()
    this

  createScene: =>
    scene = new App.Models.Scene
    scene.save storybook_id: App.currentStorybook().get('id'),
      wait: true
      success: (scene, response) =>
        @collection.add scene
        @setActiveScene scene
    return scene

  appendScene: (scene) ->
    view = new App.Views.Scene(model: scene)
    $('.scene-list').append(view.render().el)
    if scene.has "preview_image_id"
      image        = App.imageList().collection.get(scene.get('preview_image_id'))
      thumbnailUrl = image.get("url")
      activeKeyframeEl = $('.scene-list li').last().find('span')
      activeKeyframeEl.css("background-image", "url(" + thumbnailUrl + ")")

  setActiveScene: (scene) ->
    App.builder.widgetLayer.removeAllChildrenWithCleanup()
    if App.currentScene()? then App.toggleFooter()
    App.currentScene scene
    App.keyframeList().collection.scene_id = scene.get("id")
    App.keyframeList().collection.fetch()
    $('#keyframe-list').html("").html(App.keyframeList().el)
    $('nav.toolbar ul li ul li').removeClass 'disabled'

  setBackground: ->
    images         = new App.Collections.ImagesCollection []
    scene          = App.currentScene()
    image_id       = scene.get('image_id')
    background_url = ""

    images.fetch
      success: (collection, response) =>
        background_image = collection.get(image_id)
        background_url = background_image.attributes.url
        node = cc.Director.sharedDirector().getRunningScene()
        node.removeChild(node.backgroundSprite)

        cc.TextureCache.sharedTextureCache().addImage(background_url)

        node.backgroundSprite = cc.Sprite.spriteWithFile(background_url)
        node.backgroundSprite.url = background_url

        if App.currentKeyframe()
          x = App.currentKeyframe().get('background_x_coord')
          y = App.currentKeyframe().get('background_y_coord')
        else
          x = 0
          y = 0

        node.backgroundSprite.setPosition cc.ccp(x, y)
        node.addChild(node.backgroundSprite, 50)

        App.storybookJSON.addSprite(App.currentScene(), node.backgroundSprite)
        App.toggleFooter()

  clickScene: (event) ->
    target  = $(event.currentTarget)
    sceneId = target.data("id")
    sceneEl = target.parent()
    sceneEl.siblings().removeClass("active")
    sceneEl.removeClass("active")
    sceneEl.addClass("active")
    @setActiveScene @collection.get(sceneId)
    @setBackground()
