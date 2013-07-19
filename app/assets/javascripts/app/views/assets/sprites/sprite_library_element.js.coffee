class App.Views.SpriteLibraryElement extends Backbone.View
  tagName:  'li'

  template: (data) ->
    type = data.sprite.constructor.name.toLowerCase()
    JST["app/templates/assets/sprites/#{type}"](data)


  render: ->
    @$el.html(@template(sprite: @model))
    @$('.sprite-image').draggable
      helper: 'clone'
      appendTo: 'body'
      cursor: 'move'
      zIndex: 10000
      opacity: 0.5
      scroll: false
      start: @_highlightCanvas
      stop: @_removeCanvasHighlight
    @


  _highlightCanvas: =>
    $('canvas#builder-canvas').css('border', '1px solid blue')


  _removeCanvasHighlight: =>
    $('canvas#builder-canvas').css('border', '')
