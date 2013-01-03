# 1 / 0.59 = 1.69 [reciprocal of builder-canvas' scale]
ENTER_KEY_CODE = 13
SCALE_FACTOR = 1.69

class App.Views.TextWidget extends Backbone.View
  className:   'text_widget'

  events:
    'click'    : 'onClick'
    'focus'    : 'onFocus'
    'blur'     : 'onBlur'
    'paste'    : 'editActivity'
    'keyup'    : 'editActivity'
    'keypress' : 'keyPress'


  initialize: ->
    if @options.string then @content(@options.string)

    @fromToolbar = null
    @_editing =    false
    @_content =    ''

    @content      @model?.get('content')
    @setFontFace  App.currentScene().get('font_face')
    @setFontColor App.currentScene().get('font_color')
    @setFontSize  App.currentScene().get('font_size')

    @$el.css(position : 'absolute').
      attr('id', "keyframe_text_ #{@model.id}").
      draggable
        start: => App.currentKeyframeText(@model)
        stop:  => @save()


  setFontFace: (font) ->
    @$el.css 'font-family', "#{font}"


  setFontColor: (color) ->
    @$el.css 'color', "#{color}"


  setFontSize: (size) ->
    @$el.css 'font-size', "#{size}px"


  keyPress: (e) ->
    # Return false if enter key, prevent line break
    e.which isnt ENTER_KEY_CODE


  id: (_id) ->
    if _id then @id = _id else @id


  text: (_text) ->
    if _text then @$el.html(_text) else @$el.html()


  setPosition: (_left, _bottom) ->
    @$el.css
      'bottom': "#{_bottom}px"
      'left':   "#{_left}px"


  enableEditing: ->
    @$el.attr('contenteditable', 'true').focus()

    @disableDragging()

    return unless @fromToolbar
    @fromToolbar = null

    @$el.selectText()



  disableEditing: ->
    App.vent.trigger 'text_widget:done_editing'

    @$el.attr 'contenteditable', 'false'


  enableDragging: ->
    @$el.draggable 'option', 'disabled', false


  disableDragging: ->
    @$el.draggable 'option', 'disabled', true


  editing: ->
    @_editing


  fontToolbarUpdate: (fontToolbar) ->
    @$el.css
      'font-family': fontToolbar.fontFace()
      'color'      : fontToolbar.fontColor()
      'font-weight': fontToolbar.fontWeight()
      'text-align' : fontToolbar.textAlign()
      'font-size'  : "#{fontToolbar.fontSize()}px"

    @save()


  onClick: ->
    if @editing() then @disableDragging() else @enableEditing()


  onBlur: ->
    @editActivity()


  onFocus: ->
    @$el.data 'before', @$el.html()

    @editTextWidget(@)


  editTextWidget: (textWidget) ->
    App.selectedText(textWidget)

    App.vent.trigger 'text_widget:edit', textWidget

    # RFCTR: Needs ventilation
    App.keyframeTextList().editText(textWidget)
    App.currentKeyframeText(textWidget.model)


  editActivity: (e) ->
    return if @$el.data is @$el.html()

    @$el.data 'before', @$el.html()

    @save()


  deselect: ->
    @$el.blur()


  bottom: (_bottom) ->
    _offsetTop =    @$el.position().top * SCALE_FACTOR
    _offsetBottom = 768 - _offsetTop - @$el.height()
    if _bottom then @$el.css(bottom: _bottom) else _offsetBottom


  left: (_left) ->
    _offsetLeft = @$el.position().left * SCALE_FACTOR
    if _left then @$el.css(left: _left) else _offsetLeft


  content: (_content) ->
    @$el.text() unless _content

    @_content = _content
    @$el.html(_content)

  save: ->
    attributes =
      content: "Some content"
      x_coord: @left()
      y_coord: @bottom()

    @model.set(attributes)

    @model.save()