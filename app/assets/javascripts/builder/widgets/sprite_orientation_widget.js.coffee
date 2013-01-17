#= require ./widget

# The association between a SpriteWidget and a Keyframe; it stores the
# position and scale of the SpriteWidget in that Keyframe.
# RFCTR move this into a Backbone model. The WidgetLayer view will take care
# of the display stuff.
class App.Builder.Widgets.SpriteOrientationWidget extends App.Builder.Widgets.Widget
  constructor: (options = {}) ->
    throw new Error("Can not create a App.Builder.Widgets.SpriteOrientationWidget without a App.Models.Keyframe") unless (options.keyframe instanceof App.Models.Keyframe)
    super

    @keyframe = options.keyframe
    if options.x and options.y
      @point = new cc.Point(options.x, options.y)
    else
      @point = new cc.Point(300, 400)

    @scale               =    options.scale ? 1.0
    @sprite_widget_id    =    options.sprite_widget_id
    @sprite_widget       =    options.sprite_widget ? undefined
    @type                =    'SpriteOrientationWidget'


    @on 'change:orientation', @update


  toHash: ->
    hash = {}
    hash.id                  =    @id
    hash.sprite_widget_id    =    @sprite_widget_id
    hash.type                =    @type
    hash.x                   =    @point.x
    hash.y                   =    @point.y
    hash.scale               =    @scale
    hash


  save: ->
    widgets = @keyframe.get('widgets') || []
    widgets.push(@toHash())
    @keyframe.set('widgets', widgets)
    @keyframe.save({},
      success: @updateStorybookJSON
      error: @couldNotSave
    )


  update: ->
    widgets = @keyframe.get('widgets') || []
    widgetFromKeyframe = _.find(widgets, (w) -> w.id == @id)
    widgets.splice(widgets.indexOf(widgetFromKeyframe), 1, @toHash())
    @keyframe.set('widgets', widgets)
    @keyframe.save {},
      success: => console.log "App.storybookJSON.updateSpriteOrientationWidget(this)"
      error:   => console.log('SpriteOrientationWidget did not save')


  updateStorybookJSON: =>
    App.storybookJSON.addSpriteOrientationWidget(this)
    App.builder.widgetStore.addWidget(this)

  couldNotSave: =>
    console.log('could not save SpriteOrientationWidget')
