class App.Views.Modal extends Backbone.View
  modalClassName: 'content-modal'

  initialize: ->
    @modal = $(".#{@options.modalClassName || @modalClassName}")


  render: =>
    @$el.append(@options.view.render().el)
    @


  show: ->
    @modal.modal('show').html @el
    @render()


  hide: ->
    @modal.modal 'hide'
