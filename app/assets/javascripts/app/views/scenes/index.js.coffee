class App.Views.SceneIndex extends Backbone.View
  template: JST["app/templates/scenes/index"]
  tagName: 'ul'
  className: 'scene-list'
  events:
    'click    span a.delete': 'destroyScene'
    'click .scene-list span': 'clickScene'
    
  initialize: ->
    @collection.on('reset', @render, this)
    @collection.on('add', @appendScene, this)

  render: ->
    $(@el).html('')
    @collection.each (scene) => @appendScene(scene)
    $('.scene-list li:first span:first').click()
    this

  createScene: =>
    scene = new App.Models.Scene
    scene.save storybook_id: App.currentStorybook().get('id'),
      wait: true
      success: (scene, response) =>
        @collection.add scene
        @setActiveScene scene
        App.keyframeList().createKeyframe()
    return scene

  appendScene: (scene) ->
    view = new App.Views.Scene(model: scene)

    $(@el).append(view.render().el)

    if scene.has "preview_image_id"
      previewImage = App.imageList().collection.get(scene.get('preview_image_id'))
      thumbnailUrl = image.get("url")
      activeKeyframeEl.css("background-image", "url(" + thumbnailUrl + ")")

  setActiveScene: (scene) ->
    App.builder.widgetLayer.removeAllChildrenWithCleanup()

    App.currentScene scene

    App.keyframeList().collection.scene_id = scene.get("id")
    App.keyframeList().collection.fetch()

    $('#keyframe-list').html("").html(App.keyframeList().el)
    $('nav.toolbar ul li ul li').removeClass 'disabled'

  destroyScene: (event) =>
    message = '\nYou are about to delete a scene and all its keyframes.\n\n\nAre you sure you want to continue?\n'
    target  = $(event.currentTarget)
    sceneId = target.attr('data-id')
    sceneEl = target.parent().parent()
    scene   = App.sceneList().collection.get(sceneId)

    event.stopPropagation()

    if confirm(message)
      scene.destroy
        success: => sceneEl.remove() and $('.scene-list li:first span:first').click()

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

  clickScene: (event) ->
    target  = $(event.currentTarget)
    sceneId = target.data("id")
    sceneEl = target.parent()

    sceneEl.siblings().removeClass("active")
    sceneEl.removeClass("active")
    sceneEl.addClass("active")

    @setActiveScene @collection.get(sceneId)
    @setBackground()
