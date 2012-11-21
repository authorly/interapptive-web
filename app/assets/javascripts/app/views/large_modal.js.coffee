class App.Views.LargeModal extends Backbone.View
  initialize: ->
    @modal = $('.large-modal')

  render: =>
    $(@el).append @options.view.render().el
    this

  show: ->
    @modal.modal('show').html @el
    @render()

  hide: ->
    @modal.modal 'hide'
