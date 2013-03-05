class App.Views.Lightbox extends Backbone.View
  initialize: ->
    @modal = $('.lightbox-modal')


  render: ->
    @$el.append(@options.view.render().el)
    @


  show: ->
    @modal.modal('show').html @el
    @render()


  hide: ->
    @modal.modal 'hide'
