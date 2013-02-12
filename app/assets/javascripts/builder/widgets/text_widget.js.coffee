#= require ./widget

##
# A special kind of widget. It has a text property and it represents it
# graphicaly with a label.
#
# It belongs to a Keyframe.
# TODO RFCTR extract a Backbone model out of this.
#
class App.Builder.Widgets.TextWidget extends App.Builder.Widgets.Widget
  BORDER_STROKE_COLOR: 'rgba(0,0,255,1)'
  BORDER_WIDTH: 2
  SCALE: 0.59


  constructor: (options) ->
    super

    @model = options.model
    @createLabel()
    @string()

    @on 'double_click', @doubleClick

    App.vent.on 'text_widget:click_outside', @disableEditing

  # RFCTR Move initialization to the model
  # @sync_order = @model.get('sync_order ') # || @keyframe.nextTextSyncOrder()


  disableEditing: =>
    return if @getIsVisible()

    @input.hide()

    @setIsVisible(true)
    @string(@input.text())


  string: (string) ->
    if arguments.length > 0
      @label.setString(string)
      @setContentSize @label.getContentSize()
      @model.set 'string', string
    else
      @model.get('string')


  createLabel: (string) ->
    @label = cc.LabelTTF.create(@model.get('string'), 'Arial', 24)
    @label.setColor(new cc.Color3B(255, 0, 0))
    @addChild(@label)
    @setContentSize(@label.getContentSize())


  mouseOver: ->
    super
    @drawSelection()


  draw: ->
    if @_mouse_over then @drawSelection()


  drawSelection: ->
    cc.renderContext.strokeStyle = @BORDER_STROKE_COLOR
    cc.renderContext.lineWidth = @BORDER_WIDTH

    # Fix update this to have padding and solve for font below baseline
    lSize = @label.getContentSize()
    vertices = [cc.ccp(0 - lSize.width / 2, lSize.height / 2),
      cc.ccp(lSize.width / 2, lSize.height / 2),
      cc.ccp(lSize.width / 2, 0 - lSize.height / 2),
      cc.ccp(0 - lSize.width / 2, 0 - lSize.height / 2)]

    cc.drawingUtil.drawPoly(vertices, 4, true)


  doubleClick: (touch, event) =>

    @setIsVisible(false)

    # @string('Enter sime')

    @input = $('<div contenteditable="true">')
    $(cc.canvas.parentNode).append(@input)

    r = @rect()

    # Get scale factor from parent (widget layer)
    @input.css(
        'position':  'absolute'
        'top':       $(cc.canvas).position().top + $(cc.canvas).height() - r.origin.y * @SCALE - @input.height()/2
        'left':      r.origin.x * @SCALE + $(cc.canvas).position().left - @getContentSize().width * @SCALE/2 - @BORDER_WIDTH
        'min-width': "#{@getContentSize().width*0.59}px"
        'height':    '24px'
        'color':     'red'
        'border':    '1px dashed red').
      addClass('text-widget').
      text(@model.get('string')).
      selectText()
