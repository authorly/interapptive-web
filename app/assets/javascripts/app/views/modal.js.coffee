class App.Views.Modal extends Backbone.View
  initialize: ->
    @modal = $('.content-modal')

  render: =>
    $(@el).append @options.view.render().el
    this

  show: ->
    @modal.modal('show').html @el
    @render()

  hide: ->
    @modal.modal 'hide'
