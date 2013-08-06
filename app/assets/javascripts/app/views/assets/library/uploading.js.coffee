#
# The assets that are currently uploading.
#
class App.Views.UploadingAssets extends Backbone.View

  initialize: ->
    @views = []
    @container = @$('ul')
    @collection.on 'add',    @_add,    @
    @collection.on 'remove', @_remove, @


  render: ->
    @$el.hide() if @collection.length == 0


  _add: (asset) =>
    view = new App.Views.UploadingAsset(model: asset)
    viewElement = view.render().el
    @views.push view
    @container.append viewElement

    @$el.show() if @collection.length > 0


  _remove: (asset) ->
    view = _.find @views, (view) -> view.model == asset
    @views.splice(@views.indexOf(view), 1)
    view.remove()

    @$el.hide() if @collection.length == 0
