#= require ./widget

##
# A special kind of widget. It has a text property and it represents it
# graphicaly with a label.
#
# It belongs to a Keyframe.
#

class App.Builder.Widgets.TextWidget extends App.Builder.Widgets.Widget

  constructor: (options) ->
    super

    @model.on 'change:font_color change:font_id change:font_size', @recreateLabel, @

    @setAnchorPoint new cc.Point(0, 0)

    @createLabels()

    App.fontdetect.onFontLoaded @model.font().get('name'), @recreateLabel


  select: ->
    @setVisible(false)

    @editView = new App.Views.TextWidget(widget: @)
    @editView.on 'done', @doneEditing, @

    canvas = $(cc.canvas)
    $(@editView.render().el).appendTo(canvas.parent())
    @editView.initializeEditing()


  deselect: ->
    if @editView?
      @editView.shouldSave = true unless @editView.shouldSave?
      @editView.deselect()
      @editView = null
      @setVisible(true)


  doneEditing: ->
    @recreateLabel()
    @setVisible(true)
    @trigger 'deselect', @


  recreateLabel: =>
    for label in @labels
      label.removeFromParentAndCleanup()
    @createLabels()


  stringChanged: (model) ->
    @label.setString(model.get('string'))
    @setContentSize @label.getContentSize()


  createLabels: =>
    @labels = []

    fontName = @model.font().get('name')
    fontSize = @model.get('font_size')
    rgb = @model.get('font_color')
    xAnchor = switch @model.get('align')
      when 'left'   then 0
      when 'center' then 0.5
      when 'right'  then 1
    for line, i in @model.get('string').split("\n")
      label = cc.LabelTTF.create(line, fontName, fontSize)
      label.setColor(new cc.Color3B(rgb.r, rgb.g, rgb.b))

      label.setAnchorPoint(new cc.Point(xAnchor, 0))
      label.setPosition(new cc.Point(0, -(i+1) * fontSize))

      @addChild label
      @labels.push label


  mouseOver: ->
    super
    @parent.setCursor('move')
    for label in @labels
      label.setOpacity(140)


  mouseOut: ->
    super
    for label in @labels
      label.setOpacity(255)
    @parent.setCursor('default')


  rect: ->
    p = @getPosition()
    fontSize = @model.get('font_size')
    width = _.max(_.map @labels, (label) -> label.getContentSize().width)
    height = @labels.length * fontSize
    xAnchor = switch @model.get('align')
      when 'left'   then 0
      when 'center' then 0.5
      when 'right'  then 1
    yAnchor = @getAnchorPoint().y

    cc.RectMake(
      p.x + width  * (0.5 - xAnchor)
      p.y - height * (0.5 - yAnchor)
      width
      height
    )
