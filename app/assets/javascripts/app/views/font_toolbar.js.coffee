class App.Views.FontToolbar extends Backbone.View
  #template: JST['widgets/font_toolbar']
  _hidden: true
  _id: null # the current TextWidget id
  _keyframeText: null # the current KeyframeText record
  #_active: false # keeps hide() from hiding if there is a rollout event etc
  #_timer: null
  _fontColor: null # Fix set defaults color, font, size on init
  _fontSize: null
  _fontFace: null
  
  events: 
    'change .font_face select' : 'changeFontFace'
    'change .font_size select' : 'changeFontSize'
    # change color event attached to minicolors plugin in initialize: ->
    'mouseenter': 'mouseEnter'
    'mouseleave': 'mouseLeave'
    'mousemove' : 'mouseMove'
    
  initialize: ->
    console.log "FontToolbar init"
    console.log @el
    
    $(@el).find(".colorpicker").miniColors  
      change: (hex, rgb) =>
        @changeFontColor(hex, rgb)
        
  render: -> 
    #$(@el).html(@template())
    console.log "FontToolbar render"
    this #allows chaining on the view
    
  setKeyframeTextById: (id) ->
    @_id = id
    @keyframeText = @collection.get(@_id)
    #throw error if not found? set defaults
  
  keyframeText: ->
    @_keyframeText
    
  update: (e) ->
    console.log "FontToolbar update"
    @trigger('fontToolbarUpdate', @)
    
  changeFontFace: (e) ->
    #keyframeText().set
      #face : $(@el).find(".font_face select").val()
    #keyframeText().save
    console.log "FontToolbar changeFontFace " + $(@el).find(".font_face select").val()
    console.log e.srcElement.value
    @fontFace(e.srcElement.value)
    #@fontFace()
    @update()
    
  fontFace: (ff) ->
    if ff then @_fontFace = ff else @_fontFace  
    
  changeFontSize: (e) ->
    console.log "FontToolbar changeFontSize " + $(@el).find(".font_size select").val()
    keyframeText().set
      size : $(@el).find(".font_size select").val()
    keyframeText().save
    @fontSize(e.srcElement.value)
    @update()
    
  fontSize: (fs) ->
    if fs then @_fontSize = fs else @_fontSize
    
  changeFontColor: (hex, rgb) ->
    console.log "FontToolbar changeFontSize " + hex
    keyframeText().set
      color : hex
    keyframeText().save
    @fontColor(hex)
    @update()
    
  fontColor: (fc) ->
    if fc then @_fontColor = fc else @_fontColor 
      
  mouseMove: -> 
    #console.log "FontToolbar mouse move"
    #@movement()
    
  mouseEnter: ->
    #console.log "FontToolbar mouse enter"
    @_active = true
    #@movement()
  
  mouseLeave: ->
    #console.log "FontToolbar mouse leave"
    # check if rollout events happen from simple selecting a font size
    @_active = false
    #@hide()
      
  mouseOut: ->
    # hide
    #console.log "FontToolbar mouse out"
    #@hide()
    
  show: ->
    #console.log "FontToolbar show"
    $(@el).show()
    @_hidden = false
    
  setPosition: (_top, _left) ->
    # Fix calculate padding in a more clear way? 
    padding = 20 
    $(@el).css
      top : _top - ($(@el).height() + padding)
      left : _left
  
  hide: ->
    #console.log "FontToolbar hide called"
    if !@_mouseEntered
      $(@el).hide()
      @_hidden = true
    
  hidden: ->
    #console.log "FontToolbar isHidden " + @_hidden
    return @_hidden 
  
  leave: ->
    #called when view is hidden to garbage collect
  
  #movement: ->
    # somebody has hovered selected or something
    #console.log "FontToolbar movement"
    #console.log @_timer?
    #if @_timer? then @resetTimer() else @setTimer() 

  
  #setTimer: -> 
    #console.log "FontToolbar setTimer"
    #callback = -> @hide
    #@_timer = setTimeout((=> @hide()), 1000)
    #setTimeout =>
      #@hide
      #@_milliseconds

  #resetTimer: ->
    #console.log "FontToolbar resetTimer"
    #@clearTimer()
    #@setTimer()

  #clearTimer: ->
    #console.log "clearTimer"
    #clearTimeout(@_timer)

  #hover: ->
    #console.log "FontToolbar hover"
    #$(@el).data "timeout", setTimeout(alert("timeout"), @_milliseconds)

