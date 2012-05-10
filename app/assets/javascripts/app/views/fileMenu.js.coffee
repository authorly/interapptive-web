class App.Views.FileMenuView extends Backbone.View
  events:
    'click .switch-storybook': 'switchStorybook'

  render: ->
    $el = $(this.el)

  switchStorybook: ->
    $("#storybooks-modal").modal(backdrop: "static", show: true, keyboard: false)
