class App.Views.AssetsInstructions extends Backbone.View
  template: JST['app/templates/assets/library/index']

  render: ->
    @$el.html(@template())
    @


  setCollection: (collection) ->
    @collection = collection

    @collection.on 'add',    @_add,           @
    @collection.on 'remove', @_remove,        @

    if @collection.length > 0
      @_someAssetsMessage().show()
    else
      @_noAssetsMessage().show()


  _add: ->
    @_noAssetsMessage().hide()
    @_someAssetsMessage().show()


  _remove: ->
    if @collection.length == 0
      @_noAssetsMessage().show()
      @_someAssetsMessage().hide()


  _noAssetsMessage: ->
    @_no_message ||= @$el.find('.no-assets')


  _someAssetsMessage: ->
    @_some_message ||= @$el.find('.some-assets')

