#= require ./widget

##
# A special kind of widget. It has a text property and it represents it
# graphicaly with a label.
#
# It belongs to a Keyframe.
#
##
# Methods:
#   setString - Sets the cocos2d object text, ensures at least 1 character exists
#               and sets the text widget's model's string attribute (triggers a save)
#
#
#   disableEditing - Saves string to DB and removes the contentEditable
#                    overlay for editing. Done via ENTER key when editing text
#
#
#   cancelEditing - Similar to disableEditing but doesn't save. Changes are
#                   released/unsaved. Achieved via ESC key when editing text.
#
#
#   _topOffset/_leftOffset - Converts Cocos2d positions into a values which will be
#                            displayed at the same position using CSS positioning
#

class App.Builder.Widgets.TextWidget extends App.Builder.Widgets.Widget
  ESCAPE_KEYCODE = 27

  ENTER_KEYCODE =  13

  TEXT_PADDING =   14

  TEXT_PAD_BTM =   16

  TEXT_PAD_TOP =   6

  BORDER_WIDTH =   4

  BORDER_COLOR =   'rgba(15, 79, 168, 0.8)'

  SCALE =          0.59


  constructor: (options) ->
    super

    @scene = options.model.collection.keyframe.scene

    @createLabel()

    @on 'double_click', @doubleClick

    @model.on 'change:string', @stringChanged, @

    App.vent.on 'activate:scene edit:text_widget', @disableEditing, @
    App.vent.on 'change:font_face',  @fontFaceChanged,   @
    App.vent.on 'change:font_size',  @fontSizeChanged,   @
    App.vent.on 'change:font_color', @fontColorChanged,  @
    App.vent.on 'select:font_color', @fontColorSelected, @


  fontColorChanged: (rgb) ->
    @label.setColor(new cc.Color3B(rgb.r, rgb.g, rgb.b))
    @setHtmlTextColor(rgb) if @_editing()


  fontFaceChanged: (fontFace) ->
    @recreateLabel()
    @setHtmlTextFontFace(fontFace) if @_editing()


  fontSizeChanged: (fontSize) ->
    @recreateLabel()
    @setHtmlTextSize(fontSize) if @_editing()


  recreateLabel: ->
    @label.removeFromParentAndCleanup()
    @createLabel()


  setHtmlTextSize: (fontSize) ->
    $('.text-widget').css("font-size", "#{fontSize}px")
      .css('min-height', "#{fontSize}px")
      .css('top', @_topOffset())
      .css('left', @_leftOffset())


  setHtmlTextColor: (rgb) ->
    $('.text-widget').css('color',"rgb(#{rgb.r}, #{rgb.g}, #{rgb.b})")


  setHtmlTextFontFace: ->
    $('.text-widget').css('font-family', @scene.get('font_face'))


  disableEditing: (activatedScene) =>
    return if @getIsVisible()
    @setIsVisible(true)

    @_editing(false)

    if activatedScene?
      @scene = activatedScene

    @model.set 'string', @input.text()
    @input.remove()

    App.vent.trigger 'done_editing:text'


  cancelEditing: ->
    return if @getIsVisible()

    @_editing(false)
    @setIsVisible(true)
    @input.remove()


  stringChanged: (model) ->
    @label.setString(model.get('string'))
    @setContentSize @label.getContentSize()


  createLabel: ->
    @label = cc.LabelTTF.create @model.get('string'), @scene.get('font_face'), @scene.get('font_size')

    fontColor = @scene.get('font_color')
    @label.setColor(new cc.Color3B(fontColor.r, fontColor.g, fontColor.b))
    @addChild(@label)
    @setContentSize(@label.getContentSize())


  mouseOver: ->
    super
    @parent.setCursor('move')
    @label.setOpacity(155)


  mouseOut: ->
    super
    @label.setOpacity(255)


  drawSelection: ->
    cc.renderContext.strokeStyle = @BORDER_COLOR
    cc.renderContext.lineWidth = @BORDER_WIDTH

    lSize = @label.getContentSize()
    a = cc.ccp(0 - lSize.width / 2 - @TEXT_PADDING, lSize.height / 2 + @TEXT_PAD_TOP)     # top left
    b = cc.ccp(lSize.width / 2 + @TEXT_PADDING, lSize.height / 2 + @TEXT_PAD_TOP)         # top right
    c = cc.ccp(lSize.width / 2 + @TEXT_PADDING, 0 - lSize.height / 2 - @TEXT_PAD_BTM)     # bottom right
    d = cc.ccp(0 - lSize.width / 2 - @TEXT_PADDING, 0 - lSize.height / 2 - @TEXT_PAD_BTM) # bottom left
    cc.drawingUtil.drawPoly([a, b, c, d], 4, true)


  doubleClick: (touch, event) =>
    App.vent.trigger 'edit:text_widget'

    @setIsVisible(false)
    @convertLabelToEditableText()
    @initContentEditableListeners()


  initContentEditableListeners: ->
    $contentEditableEl = $('.text-widget')

    # Remove new lines when pasted into element
    $contentEditableEl.on 'input', =>
      return unless @_editing()
      return App.Lib.LinebreakFilter.filter($contentEditableEl)

    $contentEditableEl.keydown (event) =>
      @reorientateTextWidgetElement()
      if event.keyCode is @ENTER_KEYCODE then @disableEditing()
      if event.keyCode is @ESCAPE_KEYCODE then @cancelEditing()


  reorientateTextWidgetElement: ->
    $el = $('.text-widget')
    elWidth = $el.width()
    elWidth += parseInt($el.css("padding-left"), 10) + parseInt($el.css("padding-right"), 10)
    r = @rect()
    $el.css('left',r.origin.x * @SCALE - (elWidth/2) + $(cc.canvas).position().left)


  convertLabelToEditableText: =>
    color = @scene.get('font_color')
    @input = $('<div contenteditable="true">')
    @input.appendTo(cc.canvas.parentNode).css(
      'position': 'absolute'
      'color':    'red'
      'top':      @_topOffset()
      'left':     @_leftOffset()
    ).addClass('text-widget')
      .css('font-family', @scene.get('font_face'))
      .css('color',      "rgb(#{color.r}, #{color.g}, #{color.b})")
      .css('font-size',  "#{@scene.get('font_size')}px")
      .css('min-width',  "#{@getContentSize().width}px")
      .css('min-height', "#{@getContentSize().height}px")
      .text(@model.get('string'))
      .selectText()


  _leftOffset: ->
    r = @rect()
    r.origin.x * @SCALE - (@getContentSize().width / 2) + $(cc.canvas).position().left - 22


  _topOffset: ->
    r = @rect()
    $(cc.canvas).position().top + $(cc.canvas).height() - r.origin.y * @SCALE - (@getContentSize().height / 2) - @BORDER_WIDTH*2


  _editing: ->
     !@getIsVisible()
