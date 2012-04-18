class App.Models.Storybook extends Backbone.Model
  url: ->
    '/storybooks/' + this.get('id')

  toJSON: ->
    { storybook: _.clone this.attributes }

class App.Collections.StorybooksCollection extends Backbone.Collection
  model: App.Models.Storybook

  url: ->
    '/storybooks.json'
