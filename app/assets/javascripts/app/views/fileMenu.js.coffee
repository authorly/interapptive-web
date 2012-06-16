class App.Views.FileMenuView extends Backbone.View
  events:
    'click .switch-storybook': 'switchStorybook'
    'click .show-storybook-settings': 'showSettings'

  render: ->
    $el = $(this.el)

  switchStorybook: ->
    $("#storybooks-modal").modal(backdrop: "static", show: true, keyboard: false)

  showSettings: ->
    view = new App.Views.AppSettings()
    App.modalWithView(view: view).showModal()
