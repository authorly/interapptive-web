class App.Views.Modal extends Backbone.View

  render: ->
    $(@el).append @options.view.render().el
    this

  showModal: ->
    $(".content-modal").modal "show"
    $(".content-modal").html @el
    @render()
