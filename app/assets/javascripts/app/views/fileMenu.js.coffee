class App.Views.FileMenuView extends Backbone.View
  events:
    'click .create-storybook': 'createStorybook'

  render: ->
    $el = $(this.el)

  createStorybook: ->
    storybook = new App.Models.Storybook
    storybook.save user_id: App.currentUser().get('id')
    App.currentStorybook(storybook)
