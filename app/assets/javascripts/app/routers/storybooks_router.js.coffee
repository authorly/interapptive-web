class App.Routers.StorybooksRouter extends Backbone.Router
  routes:
    '' : 'index'

  index: ->
    view = new App.Views.StorybookIndex
      collection: new App.Collections.StorybooksCollection()
      el: '#storybooks'

    view.collection.fetch()
