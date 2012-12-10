class App.Builder.Widgets.Lib.SpritePositionWidget
  constructor: (options = {}) ->
    throw new Error("Can not create a App.Builder.Widgets.Lib.SpritePosition without a App.Models.Keyframe") unless (options.keyframe instanceof App.Models.Keyframe)
    throw new Error("Can not create a App.Builder.Widgets.Lib.SpritePosition without a SpriteWidget") unless (options.sprite_widget instanceof App.Builder.Widgets.SpriteWidget)

    @keyframe            =    options.keyframe
    @point               =    options.point ? new cc.Point(300, 400)
    @scale               =    options.scale ? 1.0
    @sprite_widget       =    options.sprite_widget

  toHash: ->
    hash = {}
    hash.sprite_widget_id    =    @sprite_widget.id
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

  couldNotSave: ->
    console.log('SpritePositionWidget did not save')
