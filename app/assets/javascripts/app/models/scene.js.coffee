class App.Models.Scene extends Backbone.Model
  paramRoot: 'scene'
  
  url: ->
    '/storybooks/' + App.currentStorybook().get("id") + '/scenes/' + App.currentScene().get("id")


  initialize: ->
    # FIXME hack to populate the storybooks pages
    book = @getStorybook()
    @page = book.createPage()


  # FIXME hacky method to get the storybook
  getStorybook: ->
    App.currentStorybook()


class App.Collections.ScenesCollection extends Backbone.Collection
  model: App.Models.Scene

  initialize: (models, options) ->
    if options
      this.storybook_id = options.storybook_id

  url: ->
    '/storybooks/' + this.storybook_id + '/scenes.json'
