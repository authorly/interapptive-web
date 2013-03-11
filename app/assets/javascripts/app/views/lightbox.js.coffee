class App.Views.Lightbox extends Backbone.View
  events:
    'click .lightbox-modal a.btn': 'hide'

  initialize: ->
    @modal = $('.lightbox-modal')


  render: ->
    @$el.append(@options.view.render().el)
    @


  show: ->
    @modal.modal('show').html @el
    @render()


  hide: (event) ->
    event.stopPropagation()
    @options.view.hideCallback() if @options.view.hideCallback?
    @modal.modal 'hide'
