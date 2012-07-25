class App.Views.TextWidget extends Backbone.View
  
  _editing: false
  _fontColor: null
  _fontSize: null
  _fontFace: null
  _fontToolbar: null
  
  events:
    'click' : 'onClick'
    'mouseenter' : 'mouseEnter'
    'mouseleave' : 'mouseLeave'
    'change' : 'onChange'
    'focus' : 'onFocus'
    'blur' : 'onBlur'
    'keyup' : 'editActivity'
    'paste' : 'editActivity'
    
  initialize: ->
    console.log @el
    #set edit text here instead
    #addEventListener("drop", @onDrop, this)
    # coll the colorpicker plugin
    #@collection.bind('reset', @render, this);
    #@collection.fetch()
    $(@el).draggable()
    # set font face, size, color
    @_fontToolbar = new App.Views.Widgets.FontToolbar el: $("#font_toolbar")
    
    @_fontToolbar.on('fontToolbarUpdate', @fontToolbarUpdate)
    
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
    #console.log "EditText onFocus"
    $(@el).data 'before', $(@el).html()
    # show the font toolbar
    @_fontToolbar.setPosition $(@el).offset().top, $(@el).offset().left
    @_fontToolbar.show()
    
    
  editActivity: (e) ->
    #console.log "EditText editActivity"
    if $(@el).data isnt $(@el).html()
      $(@el).data 'before', $(@el).html()
      $(@el).trigger('change')
    
  domModified: -> 
    #console.log "EditText DOMCharacterDataModified"
    
  onChange: ->
    #console.log "EditText onChange"
    #console.log $(@el).html()
    
  enableEditing: ->
    #console.log "EditText enableEditing"
    $(@el).attr("contenteditable", "true")
    @disableDragging()
    
  disableEditing: ->
    #console.log "EditText disableEditing"
    $(@el).attr("contenteditable", "false")
    
  enableDragging: ->
    #$(@el).attr("draggable", "true")
    #console.log "EditText enableDragging"
    $(@el).draggable("option", "disabled", false)
  
  disableDragging: ->
    #$(@el).attr("draggable", "false")
    #console.log "EditText disableDragging"
    $(@el).draggable("option", "disabled", true)
  
  editing: ->
    @_editing
  
  mouseEnter: (e) ->
    #console.log "EditText mouseEnter"
      
  mouseLeave: (e) ->
    #console.log "EditText mouseLeave"
      
  fontColor: (color) ->
    
  fontFace: (font) ->
    
  fontSize: (size) ->
    if size then $(@el).css('font-size', size) else @_fontSize
      