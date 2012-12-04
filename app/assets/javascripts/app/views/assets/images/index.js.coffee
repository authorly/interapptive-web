##
# A base view that allows selecting an `Image` from an `ImagesCollection`
#
class App.Views.ImageIndex extends Backbone.View
  template: JST["app/templates/assets/images/index"]


  events:
    'click a':                        'setActiveImage'
    'touchstart, touchend .zoomable': 'doZoom'
    # 'click .use-image': 'setSceneBackground'
    'click .use-image':               'selectImage'


  initialize: ->
    super
    @image = null # the selected image
    @container = @$('ul')


  render: ->
    @$el.html @template(options: @options)
    @collection.each @appendImage

    @delegateEvents() # patch for re-delegating events when the view is lost

    @


  appendImage: (image) =>
    view = new App.Views.Image(model: image)
    @container.append view.render().el


  setActiveImage: (event) ->
    event.preventDefault() # stop default behavior of sender element

    @$('.use-image').removeClass('disabled')

    sender  = @$(event.currentTarget)
    parent  = sender.parent()
    parent.addClass('zoomed-in')
    parent.siblings().addClass('zoomable').removeClass('zoomed-in')
    parent.children().removeClass('selected')
    sender.addClass('selected')

    imageId = sender.data('id')
    @image   = @collection.get(imageId)


  selectImage: ->
    @trigger('select', @image)


  doZoom: ->
    $('.zoomable').toggleClass('zoomed-in')

  # Not used. Should not be in this view; the interested party (in this case,
  # the current scene) should listen for the `select` event.
  # setSceneBackground: ->
    # url = @image.get('url')
    # App.currentScene().set('image_id', @imageId)
    # App.currentScene().save {},
      # success: (model, response) =>
        # @node = cc.Director.sharedDirector().getRunningScene()
        # cc.TextureCache.sharedTextureCache().addImage(url)
        # @node.removeChild @node.backgroundSprite
        # @node.backgroundSprite = new cc.Sprite
        # @node.backgroundSprite.initWithFile(url)

        # # FIXME need to store the url someplace cleaner
        # @node.backgroundSprite.url = url

        # @node.backgroundSprite.setPosition cc.ccp(500, 300)
        # @node.addChild @node.backgroundSprite

        # App.storybookJSON.addSprite(App.currentScene(), @node.backgroundSprite)
        # App.modalWithView().hide()
