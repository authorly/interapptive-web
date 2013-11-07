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
    @createLabel()
    @model.on 'change:font_color change:font_id change:font_size', @recreateLabel, @


  select: ->
    @setIsVisible(false)

    @editView = new App.Views.TextWidget(widget: @)
    @editView.on 'done', @doneEditing, @

    canvas = $(cc.canvas)
    $(@editView.el).appendTo(canvas.parent())
    @editView.initializeEditing()


  deselect: ->
    if @editView?
      @editView.shouldSave = true unless @editView.shouldSave?
      @editView.deselect()
      @editView = null
      @setIsVisible(true)


  doneEditing: ->
    @recreateLabel()
    @setIsVisible(true)
    @trigger 'deselect', @


  recreateLabel: ->
    @label.removeFromParentAndCleanup()
    @createLabel()


  stringChanged: (model) ->
    @label.setString(model.get('string'))
    @setContentSize @label.getContentSize()


  createLabel: =>
    @label = cc.LabelTTF.create(@model.get('string'), @model.font(), @model.get('font_size'))

    rgb = @model.get('font_color')
    @label.setColor(new cc.Color3B(rgb.r, rgb.g, rgb.b))

    @label.setAnchorPoint(new cc.Point(0, 0))

    @addChild(@label)
    @setContentSize(@label.getContentSize())


  mouseOver: ->
    super
    @parent.setCursor('move')
    @label.setOpacity(140)


  mouseOut: ->
    super
    @label.setOpacity(255)
    @parent.setCursor('default')


  rect: ->
    p = @getPosition()
    s = @getContentSize()

    cc.RectMake(
      p.x + s.width / 2
      p.y + s.height / 2
      s.width
      s.height
    )
