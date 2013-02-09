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


  constructor: (options) ->
    super

    @model = options.model
    @createLabel(@model.get('string'))
    @string(@model.get('string'))

    @on 'double_click', @doubleClick

    App.vent.on 'text_widget:click_outside', @disableEditing

  # RFCTR Move initialization to the model
  # @sync_order = @model.get('sync_order ') # || @keyframe.nextTextSyncOrder()


  disableEditing: ->
    @input.hide()
    @setIsVisible(true)


  string: (str) ->
    if arguments.length > 0
      @_string = str

      @label.setString(@_string)
      @setContentSize(@label.getContentSize())
    else
      @_string


  createLabel: (string) ->
    @label = cc.LabelTTF.create(string, 'Arial', 24)
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
    @string($('#font_settings').show())

    @input = $('<div contenteditable="true">')
    $(cc.canvas.parentNode).append(@input)

    r = @rect()

    @input.css(
      'position': 'absolute'
      'top': $(cc.canvas).position().top + $(cc.canvas).height() - r.origin.y* 0.59 - @input.height()/2
      'left': r.origin.x*0.59 + $(cc.canvas).position().left - @getContentSize().width*0.59/2 - @BORDER_WIDTH
      'height': '24px'
      'color': 'red'
      'min-width': "#{@getContentSize().wid th*0.59}px"
      'border': '1px dashed red'
    ).addClass('text-widget').
      text 'Enter some text...'
