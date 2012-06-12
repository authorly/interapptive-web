class App.Views.ImageIndex extends Backbone.View
  template: JST["app/templates/assets/images/index"]
  events:
    "click a": "setActiveImage"
    "touchstart, touchend .zoomable": "zoomSequence"
    "click .use-image": "setSceneBackground"

  initialize: ->
    @collection.bind('reset', @render, this);
    @collection.fetch()

  render: ->
    $(@el).html(@template())
    @collection.each (image) => @appendImage(image)
    @delegateEvents() # patch for re-delegating events when the view is lost
    this

  appendImage: (image) ->
    view = new App.Views.Image(model: image)
    $(@el).find('ul').append(view.render().el)

  setActiveImage: (event) ->
    event.preventDefault()
    @submit  = $(@el).find('.use-image')
    @sender  = $(event.currentTarget)
    @imageId = @sender.addClass('selected').data('id')
    @image   = @collection.get(@imageId)
    @parent  = @sender.parent()
    @submit.removeClass('disabled')
    @parent.addClass('zoomed-in')
    @parent.siblings().addClass('zoomable').removeClass('zoomed-in').children('a').removeClass('selected')

  zoomSequence: ->
    $('.zoomable').toggleClass('zoomed-in')

  setSceneBackground: ->
    url = @image.get('url')
    App.currentScene().set('image_id', @imageId)
    App.currentScene().save {},
      success: (model, response) =>
        @node = cc.Director.sharedDirector().getRunningScene()
        cc.TextureCache.sharedTextureCache().addImage(url)
        @node.backgroundSprite = cc.Sprite.spriteWithFile(url)
        @node.backgroundSprite.setAnchorPoint cc.ccp(0.5, 0.5)
        @node.backgroundSprite.setPosition cc.ccp(500, 300)
        @node.addChild @node.backgroundSprite
        App.modalWithView().hide()
