class App.Views.TextWidget extends Backbone.View
  
  _editing: false
  _fontColor: null
  _fontSize: null
  _fontFace: null
  _fontToolbar: null
  _x: 0
  _y: 0
  
  events:
    'click' : 'onClick'
    'mouseenter' : 'mouseEnter'
    'mouseleave' : 'mouseLeave'
    'change' : 'onChange'
    'focus' : 'onFocus'
    'blur' : 'onBlur'
    'keyup' : 'editActivity'
    'paste' : 'editActivity'
  
  @newFromHash: (hash) ->
    widget = new this(id: hash.id)

    widget.setPosition(hash.position.x, hash.position.y) if hash.position

    if hash.id >= NEXT_WIDGET_ID
      NEXT_WIDGET_ID = hash.id + 1

    return widget
  
  constructor: (options={}) ->
    if options.id
      @id = options.id
    else
      @id = NEXT_WIDGET_ID
      NEXT_WIDGET_ID += 1
      
  initialize: ->
    console.log "TextWidget initialize"
    console.log @el
    $(@el).draggable()
    # set font face, size, color
    @_fontToolbar = new App.Views.FontToolbar el: $("#font_toolbar")
    @_fontToolbar.on('fontToolbarUpdate', @fontToolbarUpdate)

  toHash: ->
    { id: @id
    , type: Object.getPrototypeOf(this).constructor.name
    , position: { x: @x() #$(@el).offset().left() #@getPosition().x
                , y: @y() #$(@el).offset().top() #@getPosition().y
                }
    }
    
  x: (_x) ->
    if _x then @_x = _x else @_x
  
  y: (_y) ->
    if _y then @_y = _y else @_y
    
  getText: ->
    # Fix need to solve for multiple lines and html formatting
    str = "" 
    $(@el).find('div').each(-> str = str + $(this).text())
    str
    
  setPosition: (_x, _y) ->
    $(@el).css
      'top' : _x
      'left' : _y
      
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
    
  fontFace: (font) ->
    
  fontSize: (size) ->
    if size then $(@el).css('font-size', size) else @_fontSize
      
  # events...

  update: (e) ->

  fontToolbarUpdate: (_fontToolbar) =>
    $(@el).css
      "font-family" : @_fontToolbar.fontFace()
      "font-size" : @_fontToolbar.fontSize() + "px"
      "color" : @_fontToolbar.fontColor()

  onClick: (e) ->
    console.log "EditText onClick"
    # select and make editable. once editable, another click will place the cursor inside and allow typing, i.e. "double click"
    if @editing() then @disableDragging() else @enableEditing()
    # then we have a double click
    # TODO set timer and turn off content editable

  onBlur: (e) ->
    #@_fontToolbar.hide()
    @editActivity()

  onFocus: (e) ->
    $(@el).data 'before', $(@el).html()
    # show the font toolbar
    @_fontToolbar.setPosition $(@el).offset().top, $(@el).offset().left
    @_fontToolbar.show()

  mouseEnter: (e) ->
    #console.log "EditText mouseEnter"

  mouseLeave: (e) ->
    #console.log "EditText mouseLeave"


  editActivity: (e) ->
    #console.log "EditText editActivity"
    if $(@el).data isnt $(@el).html()
      $(@el).data 'before', $(@el).html()
      $(@el).trigger('change')

  rect: ->
    # probably not needed since this is no longer cocos2d

