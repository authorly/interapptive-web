class App.Views.AssetLibraryElement extends Backbone.View
  tagName:  'li'

  template: (data) ->
    type = data.asset.constructor.name.toLowerCase()
    JST["app/templates/assets/library/#{type}"](data)


  render: ->
    @$el.
      html(@template(asset: @model)).
      prop('title', @title())
    @_createDraggable()

    @


  remove: ->
    super
    @_removeDraggable()


  title: ->
    "#{@model.get('name')}\n#{App.Lib.NumberHelper.numberToHumanSize(@model.get('size'))}\nUploaded #{App.Lib.DateTimeHelper.timeToHuman(@model.get('created_at'))}"


  _createDraggable: ->
    @$('.asset').draggable
      helper: 'clone'
      appendTo: 'body'
      cursor: 'move'
      zIndex: 10000
      opacity: 0.5
      scroll: false
      start: (-> App.vent.trigger('assetDrag-start'))
      stop:  (-> App.vent.trigger('assetDrag-stop'))


  _removeDraggable: ->
    @$('.asset').draggable('destroy')
