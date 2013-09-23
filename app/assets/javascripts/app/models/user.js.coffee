class App.Models.User extends Backbone.Model

  url: ->
    '/user'

  canMakeMoreStorybooks: ->
    @storybooks().length >= @get('allowed_storybooks_count')


  storybooks: ->
    @_storybooks ||= new App.Collections.StorybooksCollection()


  hasStorybookWithTitle: (title) ->
    @storybooks().findWhere(title: title)
