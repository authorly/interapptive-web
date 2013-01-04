##
# A base view that allows selecting an `Image` from an `ImagesCollection`
#
class App.Views.ImageIndex extends Backbone.View
  template: JST['app/templates/assets/images/index']

  events:
    'click a'                       : 'setActiveImage'
    'touchstart, touchend .zoomable': 'doZoom'
    'click .use-image'              : 'selectImage'


  initialize: ->
    super
    @image = null # the selected image
    @container = @$('ul')


  render: ->
    @$el.html @template(options: @options)
    @collection.each @appendImage
    @delegateEvents() # patch for re-delegating events when the view is lost
    @


  appendImage: (image) ->
    view = new App.Views.Image(model: image)
    @container.append view.render().el


  setActiveImage: (event) ->
    event.preventDefault()

    @$('.use-image').removeClass('disabled')
    @$(event.currentTarget).parent().addClass('zoomed-in').
      siblings().addClass('zoomable').removeClass('zoomed-in').
      children().removeClass('selected')
    @$(event.currentTarget).addClass('selected')

    @image = @collection.get @$(event.currentTarget).parent().data('id')


  selectImage: ->
    @trigger('select', @image)


  doZoom: ->
    $('.zoomable').toggleClass 'zoomed-in'