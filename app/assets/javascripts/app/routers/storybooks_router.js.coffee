class App.Routers.StorybooksRouter extends Backbone.Router
  routes:
    '' : 'index'
  
  initialize: ->
    @collection = new App.Collections.StorybooksCollection()
    @collection.fetch()

  index: ->
	  view = new App.Views.StorybookIndex(collection: @collection)
   $('#storybooks').html(view.render().el)