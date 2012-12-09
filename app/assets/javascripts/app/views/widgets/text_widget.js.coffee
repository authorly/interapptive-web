# 1 / 0.59 [scale of builder-canvas]
SCALE_FACTOR = 1.69
ENTER_KEY =    13

class App.Views.TextWidget extends Backbone.View
  className:   "text_widget"
  fromToolbar: null
  _editing:    false
  _fontColor:  "#FF0000"
  _fontFace:   "Arial"
  _fontWeight: "normal"
  _textAlign:  "left"
  _content:    ""
  _fontSize:   12
  _x:          100
  _y:          100
  _width:      100
  _height:     20


  events:
    'click'      : 'onClick'
    'mouseenter' : 'mouseEnter'
    'mouseleave' : 'mouseLeave'
    'focus'      : 'onFocus'
    'blur'       : 'onBlur'
    'keyup'      : 'editActivity'
    'paste'      : 'editActivity'
    'drag'       : 'drag'
    'keypress'   : 'keyPress'


  initialize: ->
    @content @options.string if @options.string

    @setDefaults()

    $(@el).
      css(position : 'absolute').
      attr('id', 'keyframe_text_' + @model.id).
      draggable
        start: @startDrag
        stop: @drop

    @canvas = @getCanvas()


  render: ->
    this


  setDefaults: ->
    @content    @model?.get('content') ? @_content
    @fontColor  @model?.get('color')   ? @_fontColor
    @fontSize   @model?.get('size')    ? @_fontSize
    @fontFace   @model?.get('face')    ? @_fontFace
    @fontWeight @model?.get('weight')  ? @_fontWeight
    @textAlign  @model?.get('align')   ? "left"


  keyPress: (e) ->
    e.which isnt ENTER_KEY


  id: (_id) ->
     if _id then @id = _id else @id


  getText: ->
    $(@el).html()


  setText: (text) ->
    if text then $(@el).html(text) else


  text: (_text) ->
    if _text then $(@el).html(_text) else $(@el).html()


  setPosition: (_left, _bottom) ->
    _bottomOffsetScaled = _bottom
    _leftOffsetScaled = _left
    $(@el).css
      'bottom': _bottomOffsetScaled + 'px'
      'left':   _leftOffsetScaled + 'px'


  enableEditing: ->
    $(@el).
      attr("contenteditable", "true").
      focus()

    if @fromToolbar then $(@el).selectText()
    @fromToolbar = null

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

  fontColor: (color) ->
    el = $(@el)
    if color then el.css('color', color) else el.css('color')

  fontFace: (face) ->
    el = $(@el)
    if face then el.css('font-family', face) else el.css('font-family')

  fontSize: (size) ->
    el = $(@el)
    if size then el.css('font-size', size) else el.css('font-size')

  fontWeight: (fw) ->
    el = $(@el)
    if fw then el.css('font-weight', fw) else el.css('font-weight')

  textAlign: (ta) ->
    el = $(@el)
    if ta then el.css('text-align', ta) else el.css('text-align')

  content: (_content) ->
    if _content
      $(@el).html(_content)
      @_content = _content
    else
      $(@el).html()


  drag: (e) ->


  drop: =>
    @save()


  startDrag: (e) =>
    App.currentKeyframeText(@model)

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

  mouseEnter: (e) ->

  mouseLeave: (e) ->

  editActivity: (e) ->
    if $(@el).data isnt $(@el).html()
      $(@el).data 'before', $(@el).html()
      @save()


  deselect: ->
    $(@el).blur()


  getCanvas: ->
    $('#builder-canvas')


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
      face:    @fontFace()
      size:    @fontSize()
      color:   @fontColor()
      weight:  @fontWeight()
      align:   @textAlign()
      x_coord: @left()
      y_coord: @bottom()

    @model.set attr
    @model.save()