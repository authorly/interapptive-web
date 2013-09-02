class App.Models.User extends Backbone.Model

  url: ->
    '/user'

  canMakeMoreStorybooks: ->
    @get('storybooks_count') >= @get('allowed_storybooks_count')
