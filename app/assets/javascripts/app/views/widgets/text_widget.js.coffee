# 1 / 0.59 = 1.69 [scale of builder-canvas reciprocal]
SCALE_FACTOR = 1.69
ENTER_KEY =    13

class App.Views.TextWidget extends Backbone.View
  className:   'text_widget'
  fromToolbar: null
  _editing:    false
  _content:    ''
  events:
    'click'    : 'onClick'
    'focus'    : 'onFocus'
    'blur'     : 'onBlur'
    'paste'    : 'editActivity'
    'keyup'    : 'editActivity'
    'keypress' : 'keyPress'


  initialize: ->
    @content(@options.string) if @options.string
    @setDefaults()

    $(@el).css(position : 'absolute').
      attr('id', 'keyframe_text_' + @model.id).
      draggable
        start: => App.currentKeyframeText(@model)
        stop:  => @save()


  setDefaults: ->
    @content      @model?.get('content')
    @setFontFace  App.currentScene().get('font_face')
    @setFontColor App.currentScene().get('font_color')
    @setFontSize  App.currentScene().get('font_size')


  setFontFace: (color) ->
    $el = @el
    $($el).css 'font-family', "#{color}"


  setFontColor: (color) ->
    $el = @el
    $($el).css 'color', "#{color}"


  setFontSize: (size) ->
    $el = @el
    $($el).css 'font-size', "#{size}px"


  keyPress: (e) ->
    e.which isnt ENTER_KEY  # PREVENT LINEBREAK


  id: (_id) ->
     if _id then @id = _id else @id


  text: (_text) ->
    if _text then $(@el).html(_text) else $(@el).html()


  setPosition: (_left, _bottom) ->
    $(@el).css
      'bottom': _bottom + 'px'
      'left':   _left + 'px'


  enableEditing: ->
    $el = @el
    if @fromToolbar
      $($el).selectText()
      @fromToolbar = null
    $($el).attr("contenteditable", "true").focus()

    @disableDragging()


  disableEditing: ->
    App.fontToolbar.active = false
    $(@el).attr("contenteditable", "false")


  enableDragging: ->
    $(@el).draggable("option", "disabled", false)


  disableDragging: ->
    $(@el).draggable("option", "disabled", true)


  editing: ->
    @_editing


  textAlign: (ta) ->
    el = $(@el)
    if ta then el.css('text-align', ta) else el.css('text-align')


  content: (_content) ->
    if _content
      $(@el).html(_content)
      @_content = _content
    else
      $(@el).text()


  fontToolbarUpdate: (_fontToolbar) ->
    $(@el).css
      "font-family": _fontToolbar.fontFace()
      "font-size":   _fontToolbar.fontSize() + "px"
      "color":       _fontToolbar.fontColor()
      "font-weight": _fontToolbar.fontWeight()
      "text-align":  _fontToolbar.textAlign()
    @save()


  onClick: (e) ->
    # select and make editable. once editable, another click will place the cursor inside and allow typing, i.e. "double click"
    if @editing() then @disableDragging() else @enableEditing()
    

  onBlur: ->
    if $(@el).text().length < 1 then $(@el).text("Enter some text...")
    @editActivity()


  onFocus: (e) ->
    $(@el).data 'before', $(@el).html()
    # show the font toolbar
    App.editTextWidget(this)


  editActivity: (e) ->
    if $(@el).data isnt $(@el).html()
      $(@el).data 'before', $(@el).html()
      @save()


  deselect: ->
    $(@el).blur()


  bottom: (_bottom) ->
    $el =           @el
    _offsetTop =    $($el).position().top * SCALE_FACTOR
    _offsetBottom = 768 - _offsetTop - $($el).height()

    if _bottom then $($el).css(bottom: _bottom) else _offsetBottom


  left: (_left) ->
    $el =         @el
    _offsetLeft = $($el).position().left * SCALE_FACTOR

    if _left then $($el).css(left: _left) else _offsetLeft


  save: ->
    attr =
      content: @content()
      x_coord: @left()
      y_coord: @bottom()
    @model.set attr
    @model.save()