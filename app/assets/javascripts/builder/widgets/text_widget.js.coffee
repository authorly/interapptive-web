#= require ./widget

##
# A special kind of widget. It has a text property and it represents it
# graphicaly with a label.
#
class App.Builder.Widgets.TextWidget extends App.Builder.Widgets.Widget

  constructor: (options={}) ->
    super

    @label = cc.LabelTTF.labelWithString(@_string, 'Arial', 24)
    @label.setColor(new cc.Color3B(255, 0, 0))
    @addChild(@label)
    @setString(options.string)


  setString: (string) ->
    @_string = string
    @label.setString(@_string)
    @setContentSize(@label.getContentSize())
    @trigger('change', 'string')


  getString: ->
    @_string


  mouseOver: ->
    super()
    # these methods don't exist. dira 2012-12-
    # App.selectedKeyframeText(this.id)
    # App.toggleFontToolbar(this)
    @drawSelection()


  # mouseOut: ->
    # super()
    # # these methods don't exist. dira 2012-12-03
    # # App.toggleFontToolbar(this)

  # highlight: ->
    # super()
    # #@drawSelection()


  draw: ->
    if @_mouse_over then @drawSelection()


  drawSelection: ->
    lSize = @label.getContentSize()
    cc.renderContext.strokeStyle = "rgba(0,0,255,1)"
    cc.renderContext.lineWidth = "2"
    # Fix update this to have padding and solve for font below baseline
    vertices = [cc.ccp(0 - lSize.width / 2, lSize.height / 2),
                cc.ccp(lSize.width / 2, lSize.height / 2),
                cc.ccp(lSize.width / 2, 0 - lSize.height / 2),
                cc.ccp(0 - lSize.width / 2, 0 - lSize.height / 2)]

    cc.drawingUtil.drawPoly(vertices, 4, true)


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
    hash.string = @getString()

    hash
