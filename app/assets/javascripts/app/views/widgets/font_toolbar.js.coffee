class App.Views.FontToolbar extends Backbone.View
  template: JST['app/templates/widgets/font_toolbar']
  
  className: 'font_toolbar'
  
  # defaults
  _hidden: true
  _fontColor: "#000000"
  _fontSize: 12
  _fontFace: "Arial"
  #_active: false # keeps hide() from hiding if there is a rollout event etc
  #_timer: null
  
  events: 
    'change .font_face' : 'onChangeFontFace'
    'change .font_size' : 'onChangeFontSize'
    'mouseenter': 'mouseEnter'
    'mouseleave': 'mouseLeave'
    'mousemove' : 'mouseMove'
    
  initialize: ->
    @render()
    $(@el).find(".colorpicker").miniColors  
      change: (hex, rgb) =>
        @onChangeFontColor(hex, rgb)
        
  render: (model)-> 
    $(@el).html(@template())
    this 
    
  keyframeText: (keyframeText) ->
    @_keyframeText
  
  collection: (collection) ->
    if collection then @collection = collection else @collection
  
  attachToTextWidget: (textWidget) ->
    @_textWidget(textWidget)
    @setDefaults()
    @setPosition(@_textWidget().top(), @_textWidget().left())
    @show()
    
  _textWidget: (textWidget) ->
    if textWidget then @textWidget = textWidget else @textWidget
  
  setDefaults: ->
    @fontFace @_textWidget().model?.get('face') ? @_fontFace
    @fontColor @_textWidget().model?.get('color') ? @_fontColor
    @fontSize @_textWidget().model?.get('size') ? @_fontSize
  
  update: (e) ->
    App.fontToolbarUpdate(this)
    
  onChangeFontFace: (e) ->
    @update()
    
  fontFace: (ff) ->
    if ff then $(@el).find('.font_face').val(ff) else $(@el).find(".font_face option:selected").val()
    
  onChangeFontSize: (e) ->
    @update()
    
  fontSize: (fs)->
    if fs then $(@el).find(".font_size").val(fs) else $(@el).find(".font_size option:selected").val()
    
  onChangeFontColor: (hex, rgb) ->
    @update()
    
  fontColor: (fc) ->
    if fc then $(@el).find('.colorpicker').val(fc) else $(@el).find('.colorpicker').val()
      
  mouseMove: -> 
    
  mouseEnter: ->
    @_active = true
    
  mouseLeave: ->
    @_active = false
    
  show: ()->
    $(@el).show()
    @_hidden = false
    
  setPosition: (_top, _left) ->
    # TODO calculate padding in a more clear way 
    # ENHANCEMENT may need to solve for text too high or too far to the right
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
  