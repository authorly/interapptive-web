#= require ./widget

class App.Builder.Widgets.TextWidget extends App.Builder.Widgets.Widget
  
  @newFromHash: (hash) ->
    widget = super

    widget.setString(hash.string) if hash.string

    return widget

  constructor: (options={}) ->
    super

    @_string = options.string
    
    @label = cc.LabelTTF.labelWithString(@_string, 'Arial', 24)
    @label.setColor(new cc.Color3B(255, 0, 0))

    @addChild(@label)
    @setContentSize(@label.getContentSize())

  mouseOver: ->
    super()
    App.selectedKeyframeText(this.id)
    App.toggleFontToolbar(this)
    @drawSelection()
    
  mouseOut: ->
    super()
    App.toggleFontToolbar(this)

  highlight: ->
    super()
    console.log "text widget highlight"
    #@drawSelection()

  draw: ->
    if @_mouse_over then @drawSelection()
    
  drawSelection: -> 
    lSize = @label.getContentSize()
    console.log "text widget draw selection"
    cc.renderContext.strokeStyle = "rgba(0,0,255,1)";
    cc.renderContext.lineWidth = "2";
    # Fix update this to have padding and solve for font below baseline
    vertices = [cc.ccp(0 - lSize.width / 2, lSize.height / 2), 
                cc.ccp(lSize.width / 2, lSize.height / 2), 
                cc.ccp(lSize.width / 2, 0 - lSize.height / 2), 
                cc.ccp(0 - lSize.width / 2, 0 - lSize.height / 2)]
    
    cc.drawingUtil.drawPoly(vertices, 4, true)  
  
  update: ->
    console.log "update"

  getString: ->
    @_string

  setString: (string) ->
    @_string = string
    @label.setString(@_string)
    @setContentSize(@label.getContentSize())
    @trigger('change', 'string')

  handleDoubleClick: (touch, event) =>
    @setString($('#font_settings').show())

    #input = $('<textarea>')
    #$(cc.canvas.parentNode).append(input)

    #r = @rect()

    #input.css(
    #  position: 'absolute'
    #  top: 100 + $(cc.canvas).position().top
    #  left: r.origin.x + $(cc.canvas).position().left
    #)

  toHash: ->
    hash = super
    hash.string = @_string

    hash
