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
    'mouseenter': 'mouseEnter'
    'mouseleave': 'mouseLeave'
    'mousemove' : 'mouseMove'
    
  initialize: ->
    $(@el).find(".colorpicker").miniColors  
      change: (hex, rgb) =>
        @changeFontColor(hex, rgb)
        
  render: -> 
    #$(@el).html(@template())
    this #allows chaining on the view
    
  setKeyframeTextById: (id) ->
    @_id = id
    @keyframeText = @collection.get(@_id)
    
  keyframeText: ->
    @_keyframeText
    
  update: (e) ->
    @trigger('fontToolbarUpdate', @)
    
  changeFontFace: (e) ->
    @fontFace(e.srcElement.value)
    #@fontFace()
    @update()
    
  fontFace: (ff) ->
    if ff then @_fontFace = ff else @_fontFace  
    
  changeFontSize: (e) ->
    keyframeText().set
      size : $(@el).find(".font_size select").val()
    keyframeText().save
    @fontSize(e.srcElement.value)
    @update()
    
  fontSize: (fs) ->
    if fs then @_fontSize = fs else @_fontSize
    
  changeFontColor: (hex, rgb) ->
    keyframeText().set
      color : hex
    keyframeText().save
    @fontColor(hex)
    @update()
    
  fontColor: (fc) ->
    if fc then @_fontColor = fc else @_fontColor 
      
  mouseMove: -> 
    
  mouseEnter: ->
    @_active = true
    
  mouseLeave: ->
    @_active = false
    
  show: ->
    #console.log "FontToolbar show"
    $(@el).show()
    @_hidden = false
    
  setPosition: (_top, _left) ->
    # Fix calculate padding in a more clear way 
    padding = 20 
    $(@el).css
      top : _top - ($(@el).height() + padding)
      left : _left
  
  hide: ->
    if !@_mouseEntered
      $(@el).hide()
      @_hidden = true
    
  hidden: ->
    return @_hidden 
  
  leave: ->
    #called when view is hidden to garbage collect
  