class App.Views.FileMenuView extends Backbone.View
  events:
    'click .switch-storybook': 'switchStorybook'
    'click .show-storybook-settings': 'showSettings'

  render: ->
    $el = $(this.el)

  switchStorybook: ->
    document.location.reload true

  showSettings: ->
    view = new App.Views.AppSettings()
    App.modalWithView(view: view).show()



