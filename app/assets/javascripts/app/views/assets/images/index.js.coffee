class App.Views.ImageIndex extends Backbone.View
  template: JST["app/templates/assets/images/index"]
  events:
    "click a": "setActiveImage"
    "touchstart, touchend .zoomable": "zoomSequence"
    "click .use-image": "setSceneBackground"

  initialize: ->
    @collection.fetch()

  render: ->
    $(@el).html(@template())
    @collection.each (image) => @appendImage(image)
    this

  appendImage: (image) ->
    view = new App.Views.Image(model: image)
    $(@el).find('ul').append(view.render().el)

  setActiveImage: (event) ->
    @submit    = $(@el).find('.use-image')
    @target    = $(event.currentTarget)
    @id        = @target.addClass('selected').data('id')
    @parent    = @target.parent()

    event.preventDefault()

    @submit.removeClass('disabled zoomable')
    @parent.addClass('zoomed-in')
    @parent.siblings().addClass('zoomable').removeClass('zoomed-in').children('a').removeClass('selected')

  zoomSequence: ->
    $('.zoomable').toggleClass('zoomed-in')

  setSceneBackground: ->
    App.currentScene().set('image_id', @id)
    App.currentScene().save {},
      success: (model, response) ->
        cc.Loader.shareLoader().onload = ->
          @sprite = cc.Sprite.spriteWithFile("/assets/builder/sample.jpg")
          @sprite.setAnchorPoint cc.ccp(0.5, 0.5)
          @sprite.setPosition cc.ccp(500, 300)
          @node = cc.Director.sharedDirector().getRunningScene()
          @node.addChild(@sprite)

        cc.Loader.shareLoader().preload [
           type: "image"
           src: '/assets/builder/sample.jpg'
        ]

        App.modalWithView().hide()



