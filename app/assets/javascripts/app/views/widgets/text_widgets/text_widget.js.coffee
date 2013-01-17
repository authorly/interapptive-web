# 1 / 0.59 = 1.69 [reciprocal of builder-canvas' scale]
ENTER_KEY_CODE = 13
SCALE_FACTOR = 1.69

class App.Views.TextWidget extends Backbone.View
  className:   'text_widget'

  events:
    'click'    : 'onClick'
    'focus'    : 'onFocus'
    'blur'     : 'editActivity'
    'keypress' : 'keyPress'


  initialize: ->
    throw new Error("Can not create a App.Views.TextWidget without a App.Builder.Widgets.TextWidget") unless (@options.widget instanceof App.Builder.Widgets.TextWidget)
    @widget = @options.widget

    @fromToolbar = @options.fromToolbar || null
    @_editing    = false
    @content(@widget.string())
    @setFontFace  App.currentSelection.get('scene').get('font_face')
    @setFontColor App.currentSelection.get('scene').get('font_color')
    @setFontSize  App.currentSelection.get('scene').get('font_size')

    @$el.css(position: 'absolute').
      attr('id', "keyframe_text_#{@widget.id}").
      attr('data-id', @widget.id).
      draggable
        start: => App.currentSelection.set(text_widget: @widget)
        stop:  => @update()


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


  position: ->
    @$el.css
      'bottom': "#{@widget.bottom}px"
      'left':   "#{@widget.left}px"


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


  onFocus: ->
    @$el.data 'before', @$el.html()
    @editTextWidget()


  editTextWidget: ->
    App.vent.trigger('text_widget_view:disable', @)
    App.currentSelection.set(text_widget: @widget)


  editActivity: (e) ->
    return if @$el.data is @$el.html()
    @$el.data 'before', @$el.html()
    @update()


  bottom: (_bottom) ->
    _offsetTop =    @$el.position().top * SCALE_FACTOR
    _offsetBottom = 768 - _offsetTop - @$el.height()
    if _bottom then @$el.css(bottom: _bottom) else _offsetBottom


  left: (_left) ->
    _offsetLeft = @$el.position().left * SCALE_FACTOR
    if _left then @$el.css(left: _left) else _offsetLeft


  content: (string) ->
    @$el.text() unless string
    @$el.html(string)


  update: ->
    @widget.left  = @left()
    @widget.right = @bottom()
    @widget.string(@text())
    @widget.update()
