class App.Views.LargeModal extends Backbone.View
  className: 'large-modal'

  initialize: (options={}) ->
    @$el.addClass('large-modal')
    @view = options.view

  render: =>
    @$el.html(@view.render().el)

    this

  show: ->
    @render()

  hide: ->
