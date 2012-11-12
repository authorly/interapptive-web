class App.Views.Lightbox extends Backbone.View
  initialize: ->
    @modal = $('.lightbox-modal')

  render: ->
    $(@el).append @options.view.render().el
    this

  show: ->
    @modal.modal 'show'
    @modal.html @el
    @render()

  hide: ->
    @modal.modal 'hide'
