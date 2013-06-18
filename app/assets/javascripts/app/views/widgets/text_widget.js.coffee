##
# HTML/CSS 'overlay' view for when editing a text widget.
# Uses contentEditable
#
class App.Views.TextWidget extends Backbone.View
  className: 'text-widget'

  events:
    'input': 'input'
    'keydown': 'keydown'

  ESCAPE_KEYCODE: 27

  ENTER_KEYCODE: 13

  SCALE: 0.49


  initialize: ->
    @model.on 'change:font_color', @setFontColor
    @model.on 'change:font_size', @setFontSize
    @model.on 'change:font_face', @setFontFamily

    App.vent.on 'activate:scene activate:keyframe', @stopEditingWithTextSaved, false


  render: ->
    @


  input: ->
    return App.Lib.LinebreakFilter.filter(@$el)


  keydown: (event) ->
    switch event.keyCode
      when @ENTER_KEYCODE then @stopEditingWithTextSaved(true)
      when @ESCAPE_KEYCODE then @stopEditingWithTextSaved(false)


  initializeEditing: ->
    @enableContentEditable()
    @setFontFamily()
    @setPositionFromCanvasCoords()
    @setFontSize()
    @setElementString()
    @setFontColor()
    @selectText()


  stopEditingWithTextSaved: (textShouldBeSaved) =>
    @model.set('string', @$el.text()) if textShouldBeSaved
    @model.view.resetCocos2dLabel()
    @model.view.setIsVisible(true)
    @remove()


  setElementString: ->
    @$el.text @model.get('string')


  setFontColor: =>
    rgb = @model.get('font_color')
    @$el.css("color", "rgb(#{rgb.r}, #{rgb.g}, #{rgb.b})")


  setFontFamily: =>
    @$el.css('font-family', @model.fontName())


  setFontSize: =>
    @$el.css("font-size",  "#{@model.get('font_size')}px")


  setPositionFromCanvasCoords: ->
    @canvas = @$el.parent().find('canvas')
    @$el.css
      'position': 'absolute'
      'top':      @_bottomOffset()
      'left':     @_leftOffset


  enableContentEditable: ->
    @$el.attr 'contentEditable', 'true'


  selectText: ->
    @$el.selectText()
    @$el.focus()


  _leftOffset: =>
    offset = @canvas.position().left
    offset += @model.get('position').x * @SCALE
    offset += 120


  _bottomOffset: =>
    offset = @canvas.position().top
    offset += @canvas.height()
    offset -= @model.get('position').y * @SCALE
    offset -= 219