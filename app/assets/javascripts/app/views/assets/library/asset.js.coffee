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


  title: ->
    "#{@model.get('name')}\n#{App.Lib.NumberHelper.numberToHumanSize(@model.get('size'))}\nUploaded #{App.Lib.DateTimeHelper.timeToHuman(@model.get('created_at'))}"


  # XXX remove draggable as well?
  _createDraggable: ->
    @$('.asset').draggable
      helper: 'clone'
      appendTo: 'body'
      cursor: 'move'
      zIndex: 10000
      opacity: 0.5
      scroll: false
      start: @_highlightCanvas
      stop: @_removeCanvasHighlight


  # XXX does not belong to this class
  _highlightCanvas: =>
    $('canvas#builder-canvas').css('border', '1px solid blue')


  _removeCanvasHighlight: =>
    $('canvas#builder-canvas').css('border', '')
