class App.Views.TextWidget extends Backbone.View
  #template: JST["app/templates/keyframes_text/keyframes_text"]
  
  className: "text_widget"
  
  _editing: false
  
  #defaults
  _fontColor: "#000000"
  _fontSize: 12
  _fontFace: "Arial"
  _content: "" 
  _x: 100
  _y: 100
  
  events:
    'click' : 'onClick'
    'mouseenter' : 'mouseEnter'
    'mouseleave' : 'mouseLeave'
    'focus' : 'onFocus'
    'blur' : 'onBlur'
    'keyup' : 'editActivity'
    'paste' : 'editActivity'
      
  initialize: ->
    @content @options.string if @options.string
    @setDefaults()
    $(@el).attr('contentEditable', 'false')
    $(@el).css(position : 'absolute')
    $(@el).draggable
      start: @startDrag
      stop: @drop
      
  setDefaults: ->
    @content @model?.get('content') ? @_content
    @fontColor @model?.get('color') ? @_fontColor
    @fontSize @model?.get('size') ? @_fontSize
    @fontFace @model?.get('face') ? @_fontFace
    
  id: (_id) ->
     if _id then @id = _id else @id
     
  render: ->
    this
    
  top: (_top)->
    if _top then $(@el).css(top: _top) else $(@el).offset().top
    
  left: (_left) ->
    if _left then $(@el).css(left: _left) else $(@el).offset().left
    
  x: (_x) ->
    if _x then @_x = _x else @_x
  
  y: (_y) ->
    if _y then @_y = _y else @_y
    
  getText: ->
    # Fix need to solve for multiple lines and html formatting
    # perhaps just html encode?
    #str = "" 
    #$(@el).find('div').each(-> str = str + $(this).text())
    #str
    console.log "getText #{$(@el).html()}"
    $(@el).html()
    
  setText: (text) ->
    if text then $
    
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
    @disableDragging()
    
  disableEditing: ->
    $(@el).attr("contenteditable", "false")
    
  enableDragging: ->
    $(@el).draggable("option", "disabled", false)
  
  disableDragging: ->
    $(@el).draggable("option", "disabled", true)
  
  editing: ->
    @_editing
      
  fontColor: (color) ->
    if color then $(@el).css('color' : color) else @_fontColor
    
  fontFace: (font) ->
    if font then $(@el).css('font-family') else @_fontFace
    
  fontSize: (size) ->
    if size then $(@el).css('font-size', size) else @_fontSize
  
  content: (_content) ->
    if _content 
      $(@el).html(_content)
      @_content = _content 
    else 
      @_content
  # events...
  
  #drag stop
  drop: =>
    # x_coord and y_coord are translated to cocos2d x, y starting at bottom left
    @model.set
      x_coord: @left2cocosX @left()
      y_coord: @top2cocosY @top()
    @model.save()
    
  startDrag: =>
    App.currentKeyframeText(@model)

  fontToolbarUpdate: (_fontToolbar) ->
    $(@el).css
      "font-family" : _fontToolbar.fontFace()
      "font-size" : _fontToolbar.fontSize() + "px"
      "color" : _fontToolbar.fontColor()

  onClick: (e) ->
    # select and make editable. once editable, another click will place the cursor inside and allow typing, i.e. "double click"
    if @editing() then @disableDragging() else @enableEditing()
    # TODO set timer and turn off content editable

  onBlur: (e) ->
    @editActivity()

  onFocus: (e) ->
    $(@el).data 'before', $(@el).html()
    # show the font toolbar
    App.editTextWidget(this)
    App.currentKeyframeText(@model)
    
  mouseEnter: (e) ->
    #console.log "EditText mouseEnter"

  mouseLeave: (e) ->
    #console.log "EditText mouseLeave"


  editActivity: (e) ->
    #console.log "EditText editActivity"
    if $(@el).data isnt $(@el).html()
      $(@el).data 'before', $(@el).html()
      $(@el).trigger('change')
    
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
      
  rect: ->
    # probably not needed since this is no longer cocos2d

