class App.Views.FileMenuView extends Backbone.View
  events:
    'click .switch-storybook':          'switchStorybook'
    'click .show-storybook-settings':   'showSettings'
    'click .about-authorly':            'showAbout'

  render: ->
    $el = $(this.el)

  switchStorybook: ->
    document.location.reload true

  showSettings: ->
    view = new App.Views.Storybooks.SettingsForm()
    App.modalWithView(view: view).show()

  showAbout: ->
    view = new App.Views.AboutView()
    App.modalWithView(view: view).show()
