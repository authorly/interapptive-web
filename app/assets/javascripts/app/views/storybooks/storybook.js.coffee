class App.Views.Storybook extends Backbone.View
  template: JST["app/templates/storybooks/storybook"]
  tagName: 'li'

  render: ->
    $(@el).html(@template(storybook: @model))
    this