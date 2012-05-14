class App.Views.FileMenuView extends Backbone.View
  events:
    'click .switch-storybook': 'switchStorybook'
    'click .show-storybook-settings': 'showSettings'

  render: ->
    $el = $(this.el)

  switchStorybook: ->
    $("#storybooks-modal").modal(backdrop: "static", show: true, keyboard: false)

  showSettings: ->
    settingsForm = new App.Views.AppSettings(el: $('#storybook-settings'))

    # Render() renders to our modal below
    settingsForm.render()

    $("#storybook-settings-modal").modal(backdrop: "static", show: true, keyboard: false)

