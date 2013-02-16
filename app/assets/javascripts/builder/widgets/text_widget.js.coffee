#= require ./widget

##
# A special kind of widget. It has a text property and it represents it
# graphicaly with a label.
#
# It belongs to a Keyframe.
# TODO RFCTR extract a Backbone model out of this.
#
# Methods:
#   setString - sets the cocos2d object text, ensures at least 1 character exists
#               and sets the text widget's model's string attribute (triggers a save)
#
class App.Builder.Widgets.TextWidget extends App.Builder.Widgets.Widget
  BORDER_STROKE_COLOR: 'rgba(0,0,255,1)'
  BORDER_WIDTH:  2
  SCALE:         0.59
  ENTER_KEYCODE: 13


  constructor: (options) ->
    super

    @createLabel()

    @on 'double_click', @doubleClick

    @model.on 'change:string', @stringChange, @

    # App.currentSelection.get('scene').on 'change:font_color

    App.vent.on 'edit:text_widget', @disableEditing

    # Would like for this to work properly
    # App.vent.on 'click_outside:text_widget', @disableEditing

    # Not completely sure what this is for yet
    # @sync_order = @model.get('sync_order ') # || @keyframe.nextTextSyncOrder()


  disableEditing: =>
    return if @getIsVisible()

    @setIsVisible(true)

    @model.set 'string', @input.text()

    @input.remove()


  stringChange: (model) ->
    @label.setString(model.get('string'))
    @setContentSize @label.getContentSize()


  createLabel: (string) ->
    @label = cc.LabelTTF.create(@model.get('string'), 'Arial', 24)
    scene = App.currentSelection.get('scene')
    fontColor = scene.get('font_color')
    @label.setColor(new cc.Color3B(fontColor.r, fontColor.g, fontColor.b))
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
    App.vent.trigger 'edit:text_widget'

    @setIsVisible(false)

    @input = $('<div contenteditable="true">')
    $(cc.canvas.parentNode).append(@input)

    r = @rect()

    @input.keydown (event) =>
      @disableEditing() if event.keyCode is @ENTER_KEYCODE

    # Get scale factor from parent (widget layer)
    @input.css(
        'position':  'absolute'
        'top':       $(cc.canvas).position().top + $(cc.canvas).height() - r.origin.y * @SCALE - @input.height()/2
        'left':      r.origin.x * @SCALE + $(cc.canvas).position().left - @getContentSize().width * @SCALE/2 - @BORDER_WIDTH
        'color':     'red').
      addClass('text-widget').
      text(@model.get('string')).
      selectText()
