class App.Views.FontToolbar extends Backbone.View
  template: JST['widgets/font_toolbar']
  
  @_timer = null
  @_milliseconds = 2000
  
  events: 
    'mouseout #font_toolbar'  : 'mouseOut'
    'change #font_name'       : 'update'
    'change #font_size'       : 'update'
    #'mouseover': 'mouseOver'
    'mouseenter': 'mouseEnter'
    'mouseleave': 'mouseLeave'
    'mousemove' : 'mouseMove'
    'mouseout' : 'mouseOut'
    #'hover' : 'hover'
    
  initialize: ->
    $el = $(this.el)  
    console.log "#" + $el.attr('id') + " .colorpicker" 
    $("#" + $el.attr('id') + " .colorpicker").miniColors();
    console.log "FontToolbar init"
    console.log @el
    
    #$(@el).hover(
      #-> $(this).data "timeout", setTimeout(-> alert "You have been hovering this element for 1000ms", 1000)
      #-> clearTimeout $(this).data("timeout")
    #)
    
  render: -> 
    #$(@el).html(@template())
    console.log "FontToolbar render"
    
  update: (event) ->
    console.log "FontToolbar update"
    
  hover: ->
    console.log "FontToolbar hover"
    #$(@el).data "timeout", setTimeout(alert("timeout"), @_milliseconds)
    
  mouseMove: -> 
    #console.log "FontToolbar mouse move"
    #@movement()
    
  mouseEnter: ->
    console.log "FontToolbar mouse enter"
    @movement()
  
  mouseLeave: ->
    console.log "FontToolbar mouse leave"
    #@hide()
      
  mouseOut: ->
    # hide
    #console.log "FontToolbar mouse out"
    #@hide()
    
  movement: ->
    # somebody has hovered selected or something
    console.log "FontToolbar movement"
    console.log @_timer?
    if @_timer? then @resetTimer() else @setTimer() 
    
  setTimer: -> 
    console.log "FontToolbar setTimer"
    callback = -> @hide
    @_timer = setTimeout callback, @_milliseconds  
      
  resetTimer: ->
    console.log "FontToolbar resetTimer"
    @clearTimer()
    @setTimer()
    
  clearTimer: ->
    console.log "clearTimer"
    clearTimeout(@_timer)
  
  hide: ->
    console.log "FontToolbar hide called"
    $(@el).hide()
  
  
  
  
  