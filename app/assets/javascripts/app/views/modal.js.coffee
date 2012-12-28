class App.Views.Modal extends Backbone.View
  initialize: ->
    @modal = $('.content-modal')

  render: =>
    console.log "rendering modal"
    @$el.append @options.view.render().el
    this

  show: ->
    console.log "showing modal"
    @modal.modal('show').html @el
    @render()

  hide: ->
    @modal.modal 'hide'
