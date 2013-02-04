#= require ./widget

##
# A special kind of widget. It has a text property and it represents it
# graphicaly with a label.
#
# It belongs to a Keyframe.
# TODO RFCTR extract a Backbone model out of this.
#
class App.Builder.Widgets.TextWidget extends App.Builder.Widgets.Widget

  constructor: (options) ->
    super

    @keyframe = options.keyframe
    throw new Error("Can not create a App.Builder.Widgets.TextWidget without a App.Models.Keyframe") unless (@keyframe instanceof App.Models.Keyframe)

    @createLabel(options.string)
    @string(options.string)

    # TODO RFCTR Move these initializations to the model
    @type       = 'TextWidget'
    @left       = options.left       || 400 * Math.random()
    @bottom     = options.bottom     || 350 * Math.random()
    @sync_order = options.sync_order || @keyframe.nextTextSyncOrder()


  string: (str) ->
    if arguments.length > 0
      @_string = str
      @label.setString(@_string)
      @setContentSize(@label.getContentSize())
      @trigger('change', 'string')

    else
      @_string


  createLabel: (string) ->
    @label = cc.LabelTTF.create(string, 'Arial', 24)
    @label.setColor(new cc.Color3B(255, 0, 0))
    @addChild(@label)


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
    @string($('#font_settings').show())

    #input = $('<textarea>')
    #$(cc.canvas.parentNode).append(input)

    #r = @rect()

    #input.css(
    #  position: 'absolute'
    #  top: 100 + $(cc.canvas).position().top
    #  left: r.origin.x + $(cc.canvas).position().left
    #)

  # TODO RFCTR move this to the model
  toHash: ->
    hash            =  super
    hash.string     =  @string()
    hash.type       =  @type
    hash.left       =  @left
    hash.bottom     =  @bottom
    hash.sync_order =  @sync_order

    hash

  create: ->
    widgets = @keyframe.get('widgets') || []
    widgets.push(@toHash())
    @keyframe.set('widgets', widgets)
    @keyframe.save({},
      success: @_afterCreate
      error: @_couldNotCreate
    )


  update: ->
    # RFCTR @create, @update and @destroy all have some common
    # code that fetch widgets of a keyframe and save the
    # keyframe afterwards. The common should be moved to
    # Keyframe model.
    widgets = @keyframe.get('widgets') || []
    widgetFromKeyframe = _.find(widgets, (w) -> w.id == @id)
    widgets.splice(widgets.indexOf(widgetFromKeyframe), 1, @toHash())
    @keyframe.set('widgets', widgets)
    @keyframe.save {},
      success: => console.log("TextWidget updated")
      error:   => console.log('TextWidget did not update')


  destroy: ->
    widgets = @keyframe.get('widgets') || []
    widgetFromKeyframe = _.find(widgets, (w) -> w.id == @id)
    widgets.splice(widgets.indexOf(widgetFromKeyframe), 1)
    @keyframe.set('widgets', widgets)
    @keyframe.save {},
      success: @_afterDestroy
      error:   @_couldNotDestroy


  _afterDestroy: =>
    App.builder.widgetStore.removeWidget(this)
    @keyframe.trigger('widget:text:destroy', this)
    # Remove text widget from Storybook JSON


  _afterCreate: =>
    App.builder.widgetStore.addWidget(this)
    @keyframe.trigger('widget:text:create', this)
    # Add text widget to Storybook JSON


  _couldNotCreate: =>
    console.log('TextWidget could not create')


  _couldNotDestroy: =>
    console.log('TextWidget did not destroy')
