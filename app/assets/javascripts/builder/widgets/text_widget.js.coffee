#= require ./widget

##
# A special kind of widget. It has a text property and it represents it
# graphicaly with a label.
#
# It belongs to a Keyframe.
#
# Methods:
#   setString - sets the cocos2d object text, ensures at least 1 character exists
#               and sets the text widget's model's string attribute (triggers a save)
#
class App.Builder.Widgets.TextWidget extends App.Builder.Widgets.Widget
  BORDER_STROKE_COLOR: 'rgba(15, 79, 168, 0.8)'
  BORDER_WIDTH:  4
  TEXT_PADDING:  10
  TEXT_PAD_TOP:  7
  SCALE:         0.59
  ENTER_KEYCODE: 13


  constructor: (options) ->
    super

    @createLabel()

    @on 'double_click', @doubleClick

    @model.on 'change:string', @stringChange, @

    App.vent.on 'edit:text_widget',  @disableEditing
    App.vent.on 'activate:scene',    @disableEditing
    App.vent.on 'change:font_face',  @fontFaceChanged,   @
    App.vent.on 'change:font_size',  @fontSizeChanged,   @
    App.vent.on 'change:font_color', @fontColorChanged,  @
    App.vent.on 'select:font_color', @fontColorSelected, @


  fontColorChanged: (rgb) ->
    @label.setColor(new cc.Color3B(rgb.r, rgb.g, rgb.b))


  fontFaceChanged: ->
    @label.removeFromParentAndCleanup()
    @createLabel()


  fontSizeChanged: ->
    @label.removeFromParentAndCleanup()
    @createLabel()


  disableEditing: =>
    return if @getIsVisible()
    @setIsVisible(true)

    @model.set 'string', @input.text()
    @input.remove()

    App.vent.trigger 'done_editing:text'


  stringChange: (model) ->
    @label.setString(model.get('string'))
    @setContentSize @label.getContentSize()


  createLabel: ->
    currentScene = App.currentSelection.get('scene')
    @label = cc.LabelTTF.create @model.get('string'), currentScene.get('font_face'), currentScene.get('font_size')

    fontColor = currentScene.get('font_color')
    @label.setColor(new cc.Color3B(fontColor.r, fontColor.g, fontColor.b))
    @addChild(@label)
    @setContentSize(@label.getContentSize())


  mouseOver: ->
    super
    @parent.setCursor('move')
    @drawSelection()


  mouseOut: ->
    super
    @parent.setCursor('default')


  draw: ->
    if @_mouse_over then @drawSelection()


  drawSelection: ->
    cc.renderContext.strokeStyle = @BORDER_STROKE_COLOR
    cc.renderContext.lineWidth = @BORDER_WIDTH

    lSize = @label.getContentSize()

    # top left
    a = cc.ccp(0 - lSize.width / 2 - @TEXT_PADDING, lSize.height / 2 + @TEXT_PAD_TOP)
    # top right
    b = cc.ccp(lSize.width / 2 + @TEXT_PADDING, lSize.height / 2 + @TEXT_PAD_TOP)
    # bottom right
    c = cc.ccp(lSize.width / 2 + @TEXT_PADDING, 0 - lSize.height / 2 - @TEXT_PADDING)
    # bottom left
    d = cc.ccp(0 - lSize.width / 2 - @TEXT_PADDING, 0 - lSize.height / 2 - @TEXT_PADDING)

    vertices = [a, b, c, d]
    cc.drawingUtil.drawPoly(vertices, 4, true)


  doubleClick: (touch, event) =>
    App.vent.trigger 'edit:text_widget'

    @setIsVisible(false)

    @input = $('<div contenteditable="true">')
    $(cc.canvas.parentNode).append(@input)

    r = @rect()

    @input.keydown (event) =>
      @disableEditing() if event.keyCode is @ENTER_KEYCODE

    @scene = App.currentSelection.get('scene')
    color = @scene.get('font_color')
    @input.css(
        'position':  'absolute'
        'top':       $(cc.canvas).position().top + $(cc.canvas).height() - r.origin.y * @SCALE - (@getContentSize().height / 2)
        'left':      r.origin.x * @SCALE - (@getContentSize().width / 2) + $(cc.canvas).position().left
        'color':     'red')
      .addClass('text-widget')
      .css('font-family', @scene.get('font_face'))
      .css('font-size', "#{@scene.get('font_size')}px")
      .css('color', "rgb(#{color.r}, #{color.g}, #{color.b})")
        .css('min-width', "#{@getContentSize().width}px")
        .css('min-height', "#{@getContentSize().height}px")
      .text(@model.get('string'))
      .selectText()
