class App.Views.TextWidget extends Backbone.View
  className: "text_widget"

  fromToolbar: null

  _editing: false
  _fontColor: "#FF0000"
  _fontSize: 12
  _fontFace: "Arial"
  _fontWeight: "normal"
  _textAlign: "left"
  _content: ""
  _x: 100
  _y: 100
  _width : 100
  _height : 20

  events:
    'click'      : 'onClick'
    'mouseenter' : 'mouseEnter'
    'mouseleave' : 'mouseLeave'
    'focus'      : 'onFocus'
    'blur'       : 'onBlur'
    # do focusOut to close toolbar also! should fix it.
    'keyup'      : 'editActivity'
    'paste'      : 'editActivity'
    'drag'       : 'drag'

  initialize: ->
    @content @options.string if @options.string
    @setDefaults()
    $(@el).css(position : 'absolute')
    $(@el).draggable
      start: @startDrag
      stop: @drop

    @canvas = @getCanvas() #TODO DRY up canvas calls below

  setDefaults: ->
    @content @model?.get('content') ? @_content
    @fontColor @model?.get('color') ? @_fontColor
    @fontSize @model?.get('size') ? @_fontSize
    @fontFace @model?.get('face') ? @_fontFace
    @fontWeight @model?.get('weight') ? @_fontWeight
    @textAlign @model?.get('align') ? "left"

  id: (_id) ->
     if _id then @id = _id else @id

  render: ->
    this

  getText: ->
    # FIXME need to solve for multiple lines and html formatting
    # perhaps just html encode?
    #str = ""
    #$(@el).find('div').each(-> str = str + $(this).text())
    #str
    $(@el).html()

  setText: (text) ->
    if text then $(@el).html(text) else

  text: (_text) ->
    if _text then $(@el).html(_text) else $(@el).html()

  setPosition: (_top, _left) ->
    $(@el).css
      'top' : _top
      'left' : _left

  setPositionFromCocosCoords: (_x, _y) ->
    $(@el).css
      'top' : @cocosYtoTop(_y)
      'left' : @cocosXtoLeft(_x)

  enableEditing: ->
    $(@el).attr("contenteditable", "true")
    $(@el).focus()

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

  # events...

  drag: ->
    #if calling constrainToCanvas during drag, is just overridden by next drag event
    #@constrainToCanvas()

  #drag stop
  drop: =>
    # x_coord and y_coord are translated to cocos2d x, y starting at bottom left
    @constrainToCanvas()

    @save()

  startDrag: =>
    App.currentKeyframeText(@model)

  fontToolbarUpdate: (_fontToolbar) ->
    $(@el).css
      "font-family" : _fontToolbar.fontFace()
      "font-size" : _fontToolbar.fontSize() + "px"
      "color" : _fontToolbar.fontColor()
      "font-weight" : _fontToolbar.fontWeight()
      "text-align" : _fontToolbar.textAlign()

    @constrainToCanvas()

    @save()

  onClick: (e) ->
    # select and make editable. once editable, another click will place the cursor inside and allow typing, i.e. "double click"
    if @editing() then @disableDragging() else @enableEditing()
    # TODO set timer and turn off content editable

  onBlur: ->
    # unless App.fontToolbar.active then App.fontToolbar.hide()
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

    # text may have grown outside of canvas
    @constrainToCanvas()

  deselect: ->
    $(@el).blur()
   
  top: (_top) ->
    if _top then $(@el).css(top: _top) else $(@el).offset().top
    
  left: (_left) ->
    if _left then $(@el).css(left: _left) else $(@el).offset().left
    
  x: (_x) ->
    if _x then @_x = _x else @_x
  
  y: (_y) ->
    if _y then @_y = _y else @_y
    
  width: (_w) ->
    if _w then @_w = $(@el).width(_w) else $(@el).width()
  
  height: (_h) ->
    if _h then @_h = $(@el).height(_h) else $(@el).height()
  
  
  constrainToCanvas: ->
    c = @canvas
    cTop = c.offset().top
    cLeft = c.offset().left
    cWidth = c.width()
    cHeight = c.height()
    
    #too high
    if @top() < cTop
      # TODO make more exact
      @top(cTop)
      
    #too far left
    if @left() < cLeft
      @left(cLeft)
      
    #too low
    if @top() > (cTop + cHeight)
      newTop = (cTop + cHeight) - @height()
      @top(newTop) 
      
    #too far right
    if @left() > (cLeft + cWidth) - @width()
      newLeft = (cLeft + cWidth) - @width()
      @left(newLeft)
    #animate to new positions
      
  cocosYtoTop: (_cocosY) ->
    _canvas = @getCanvas()
    _top = _canvas.offset().top + _canvas.height() - _cocosY
    _top
    
  cocosXtoLeft: (_cocosX) ->
    _canvas = @getCanvas()
    _left = _canvas.offset().left + _cocosX
    
  top2cocosY: (_top) ->
    _canvas = @getCanvas()
    _y = _canvas.height() - (@top() - _canvas.offset().top)
    _y
    
  left2cocosX: (_left) ->
    _canvas = @getCanvas()
    _x = @left() - _canvas.offset().left
    _x
    
  cocosX: ->
    @left2cocosX @left()
    
  cocosY: ->
    @top2cocosY @top()
    
  getCocosPosition: ->
    {
      x: @cocosX()
      y: @cocosY()
    }
    
  getCanvas: ->
    $('#builder-canvas')
    
  save: ->
    attr =
      content : @content()
      face : @fontFace()
      size : @fontSize()
      color : @fontColor()
      weight : @fontWeight()
      align : @textAlign()
      x_coord : @cocosX()
      y_coord : @cocosY()
    @model.set attr
    @model.save
      success: ->
        
  rect: ->
    # probably not needed since this is no longer cocos2d

