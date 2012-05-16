class App.Views.FileMenuView extends Backbone.View
  events:
    'click .switch-storybook': 'switchStorybook'
    'click .show-storybook-settings': 'showSettings'

  render: ->
    $el = $(this.el)

  switchStorybook: ->
    $("#storybooks-modal").modal(backdrop: "static", show: true, keyboard: false)

  showSettings: ->
    set_mod = new App.Views.AppSettings()
    App.modalWithView(view: set_mod).showModal()



