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

  toHash: ->
    hash = {}
    hash.sprite_widget_id    =    @sprite_widget_id
    hash.x                   =    @point.x
    hash.y                   =    @point.y
    hash.scale               =    @scale
    hash

  save: ->
    widgets = @keyframe().get('widgets') || []
    widgets.push(@toHash())
    @keyframe().set('widgets', widgets)
    @keyframe().save().
      success(@updateStorybookJSON).
      error(@couldNotSave)

  updateStorybookJSON: ->
    App.storybookJSON.addSpritePositionWidget(this)
    App.builder.widgetStore.addWidget(this)

  couldNotSave: ->
    console.log('SpriteOrientationWidget did not save')
