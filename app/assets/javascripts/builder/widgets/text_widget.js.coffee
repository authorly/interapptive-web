#= require ./widget

class App.Builder.Widgets.TextWidget extends App.Builder.Widgets.Widget
  @_selection_border = null
  @_selection_drawn = false
  @_selection_border = null

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

    @on('dblclick', @handleDoubleClick)

  highlight: ->
    super()
    console.log "text widget highlight"
    #@drawSelection()

  draw: ->
    if @isHighlighted() then @drawSelection()
    
  drawSelection: -> 
    console.log @label.getContentSize()
    lSize = @label.getContentSize()
    console.log "selection drawn " + @_selection_drawn
    console.log "text widget draw selection"
    cc.renderContext.strokeStyle = "rgba(255,0,255,1)";
    cc.renderContext.lineWidth = "2";
    #s = @contentSize()
    vertices = [cc.ccp(0, 0), cc.ccp(lSize.width, 0), cc.ccp(lSize.width, lSize.height), cc.ccp(0, lSize.height)]
    @_selection_border = cc.drawingUtil.drawPoly(vertices, 4, true)  
    #@_selection_drawn = true
  
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
