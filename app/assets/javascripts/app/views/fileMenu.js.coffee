class App.Views.FileMenuView extends Backbone.View
  events:
    'click .switch-storybook': 'switchStorybook'

  render: ->
    $el = $(this.el)

  switchStorybook: ->
    $("#myStorybooksModal").modal(backdrop: "static", show: true, keyboard: false)
