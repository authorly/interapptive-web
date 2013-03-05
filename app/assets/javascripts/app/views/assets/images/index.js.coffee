##
# A base view that allows selecting an `Image` from an `ImagesCollection`
#
class App.Views.ImageIndex extends Backbone.View
  template: JST['app/templates/assets/images/index']

  events:
    'click .image-row' : 'setActiveImage'
    'click .use-image' : 'selectImage'


  render: ->
    @$el.html @template(options: @options)

    @collection.each @appendImage

    @delegateEvents() # patch for re-delegating events when the view is lost

    @


  appendImage: (image) ->
    view = new App.Views.Image(model: image)

    @$('ul').append view.render().el


  setActiveImage: (event) ->
    @$(event.currentTarget).addClass('selected').siblings().removeClass 'selected'
    @$('.use-image').removeClass('disabled')

    @image = @collection.get @$(event.currentTarget).data('id')


  selectImage: ->
    @trigger('select', @image)
