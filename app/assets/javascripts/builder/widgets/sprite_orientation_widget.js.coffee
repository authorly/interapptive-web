#= require ./widget

class App.Builder.Widgets.SpriteOrientationWidget extends App.Builder.Widgets.Widget
  constructor: (options = {}) ->
    throw new Error("Can not create a App.Builder.Widgets.SpriteOrientationWidget without a App.Models.Keyframe") unless (options.keyframe instanceof App.Models.Keyframe)
    super

    @keyframe            =    options.keyframe
    @point               =    options.point ? new cc.Point(300, 400)
    @scale               =    options.scale ? 1.0
    @sprite_widget_id    =    options.sprite_widget_id
    @sprite_widget       =    options.sprite_widget ? undefined


    @on 'change:orientation', @update


  toHash: ->
    hash = {}
    hash.sprite_widget_id    =    @sprite_widget_id
    hash.type                =    Object.getPrototypeOf(this).constructor.name
    hash.x                   =    @point.x
    hash.y                   =    @point.y
    hash.scale               =    @scale
    hash


  save: ->
    widgets = @keyframe.get('widgets') || []
    widgets.push(@toHash())
    @keyframe.set('widgets', widgets)
    @keyframe.save({},
      success: => @updateStorybookJSON
      error: => @couldNotSave
    )


  update: ->
    console.log "update spriteOrientationWidget"
    orientationWidgets = @keyframe.get('widgets') || []
    widgetFromKeyframe = _.find(orientationWidgets, (w) -> w.id == @id)
    orientationWidgets.splice(orientationWidgets.indexOf(widgetFromKeyframe), 1, @toHash())
    @keyframe.set('widgets', orientationWidgets)
    @keyframe.save {},
      success: =>
        console.log('Update widget in widget store')
        console.log('Update widget JSON')
      error: =>
        console.log("FFFFFFFFFuuuuuuuuu")


  updateStorybookJSON: ->
    App.storybookJSON.addSpriteOrientationWidget(this)
    App.builder.widgetStore.addWidget(this)

  couldNotSave: ->
    console.log('SpriteOrientationWidget did not save')
