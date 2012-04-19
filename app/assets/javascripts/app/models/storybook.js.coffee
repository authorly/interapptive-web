class App.Models.Storybook extends Backbone.Model
  paramRoot: 'storybook'

  url: ->
    base = 'storybooks'

class App.Collections.StorybooksCollection extends Backbone.Collection
  model: App.Models.Storybook

  url: ->
    '/storybooks.json'
