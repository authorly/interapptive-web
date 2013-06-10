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
  ESCAPE_KEYCODE: 27
  ENTER_KEYCODE:  13
  TEXT_PADDING:   14
  TEXT_PAD_BTM:   16
  TEXT_PAD_TOP:   6
  SCALE:          0.49
  BORDER_WIDTH:   4
  BORDER_COLOR:   'rgba(15, 79, 168, 0.8)'
  DEFAULT_TEXT:   'Enter some text...'


  constructor: (options) ->
    super

    @createLabel()

    @on 'double_click', @doubleClick

    @model.on 'change:string',                   @stringChanged,    @
    @model.on 'change:font_face change:font_id', @fontFaceChanged,  @
    @model.on 'change:font_size',                @fontSizeChanged,  @
    # change:visual_font_color signals a temporary change of
    # the color. This color is not persisted in the widget's
    # attributes unless the change is confirmed by the user.
    # This event is used only to communicate in between views
    # that alter / display the widget.
    @model.on 'change:visual_font_color',        @fontColorChanged, @


  shouldBeEditable : ->
    @model.get('string') is @DEFAULT_TEXT


  fontColorChanged: (rgb) ->
    @label.setColor(new cc.Color3B(rgb.r, rgb.g, rgb.b))
    @setHtmlTextColor(rgb) if @_editing()


  fontFaceChanged: ->
    @recreateLabel()
    @setHtmlTextFontFace() if @_editing()


  fontSizeChanged: (__, size) ->
    @recreateLabel()
    @setHtmlTextSize(size) if @_editing()


  recreateLabel: ->
    @label.removeFromParentAndCleanup()
    @createLabel()


  setHtmlTextSize: (size) ->
    @_textWidgetElement().css("font-size", "#{size}px")
      .css('min-height', "#{size}px")
      .css('top', @_topOffset())
      .css('left', @_leftOffset())


  setHtmlTextColor: (rgb) ->
    @_textWidgetElement().css('color',"rgb(#{rgb.r}, #{rgb.g}, #{rgb.b})")


  setHtmlTextFontFace: ->
    @_textWidgetElement().css('font-family', @model.font()?.get('name'))


  disableEditing: =>
    return if @getIsVisible()
    @setIsVisible(true)

    @_editing(false)

    @model.set 'string', @input.text()
    @input.remove()

    @trigger 'deselect', @
    App.vent.trigger 'done_editing:text'


  deselect: ->
    @cancelEditing()


  cancelEditing: ->
    return if @getIsVisible()

    @_editing(false)
    @setIsVisible(true)
    @input.remove()

    @trigger 'deselect', @
    App.vent.trigger 'done_editing:text'


  stringChanged: (model) ->
    @label.setString(model.get('string'))
    @setContentSize @label.getContentSize()


  createLabel: ->
    @label = cc.LabelTTF.create @model.get('string'), @model.font()?.get('name'), @model.get('font_size')

    fontColor = @model.get('font_color')
    @label.setColor(new cc.Color3B(fontColor.r, fontColor.g, fontColor.b))

    @label.setAnchorPoint(new cc.Point(0, 0))

    @addChild(@label)
    @setContentSize(@label.getContentSize())


  mouseOver: ->
    super
    @parent.setCursor('move')
    @label.setOpacity(155)


  mouseOut: ->
    super
    @label.setOpacity(255)
    @parent.setCursor('default')


  doubleClick: (touch, event) =>
    @disableEditing()

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
    elWidth = $el.width() * @SCALE
    elWidth += parseInt($el.css("padding-left"), 10) + parseInt($el.css("padding-right"), 10)
    r = @rect()
    $el.css('left',r.origin.x * @SCALE + $(cc.canvas).position().left - (@label.getContentSize().width / 2) * @SCALE - 50)


  convertLabelToEditableText: =>
    # REFACTOR: Following is way too much logic here.
    # Probably extract out TextWidget element on canvas
    # in its own view.
    color = @model.get('font_color')
    @input = $('<div contenteditable="true">')
    @input.appendTo(cc.canvas.parentNode)
      .attr('data-text-widget-id', @model.get('id'))
      .css(
        'position': 'absolute'
        'color':    'red'
        'top':      @_topOffset()
        'left':     @_leftOffset())
      .addClass('text-widget')
      .css('font-family', @model.font()?.get('name'))
      .css('color',      "rgb(#{color.r}, #{color.g}, #{color.b})")
      .css('font-size',  "#{@model.get('font_size')}px")
      .css('min-width',  "#{@getContentSize().width}px")
      .css('min-height', "#{@getContentSize().height}px")
      .text(@model.get('string'))
      .selectText()


  _leftOffset: ->
    r = @rect()
    r.origin.x * @SCALE - (@getContentSize().width / 2) + $(cc.canvas).position().left + 120


  _topOffset: ->
    r = @rect()
    $(cc.canvas).position().top + $(cc.canvas).height() - r.origin.y * @SCALE - (@getContentSize().height / 2) - @BORDER_WIDTH*2 - 190


  _editing: ->
     !@getIsVisible()

  _textWidgetElement: ->
    @_text_widget_element ||= $("[data-text-widget-id='#{@model.get('id')}']")
