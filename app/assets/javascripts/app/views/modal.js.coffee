class App.Views.Modal extends Backbone.View

  render: ->
    @$el.html('').append @options.view.render().el
    @


  show: ->
    @render()
    @$el.modal 'show'


  hide: ->
    @$el.modal 'hide'


  onHidden: ->
    @options.view.remove()
