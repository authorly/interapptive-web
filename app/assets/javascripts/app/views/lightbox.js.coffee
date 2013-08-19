class App.Views.Lightbox extends Backbone.View

  initialize: ->
    @modal = $('.lightbox-modal')
    @modal.on 'click', 'a.btn', @hide
    @modal.on 'hide', @hidden


  render: ->
    @$el.append(@options.view.render().el)
    @


  show: ->
    @modal.modal('show').html @el
    @render()


  hide: (event) =>
    event.stopPropagation()
    @modal.modal 'hide'


  hidden: =>
    @options.view.hideCallback() if @options.view.hideCallback?
    @modal.off 'click', 'a.btn', @hide
