class App.Models.Storybook extends Backbone.Model
  paramRoot: 'storybook'

  url: ->
    'storybooks'

class App.Collections.StorybooksCollection extends Backbone.Collection
  model: App.Models.Storybook

  url: ->
    '/storybooks.json'

  comparator: (storybook) ->
    date = new Date(storybook.get('created_at'));
    -date
    
  