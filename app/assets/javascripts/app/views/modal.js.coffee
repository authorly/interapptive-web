class App.Views.Modal extends Backbone.View
  initialize: ->
    @modal = $('.content-modal')


  render: =>
    @$el.append(@options.view.render().el)
    @


  show: ->
    App.vent.trigger 'show:modal'

    @modal.modal('show').html @el
    @render()


  hide: ->
    @modal.modal 'hide'
