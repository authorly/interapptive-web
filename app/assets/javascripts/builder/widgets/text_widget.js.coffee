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
    @setVisible(false)

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
      @setVisible(true)


  doneEditing: ->
    @recreateLabel()
    @setVisible(true)
    @trigger 'deselect', @


  recreateLabel: ->
    @label.removeFromParent()
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
    cc.rect(
      p.x
      p.y
      s.width
      s.height
    )
