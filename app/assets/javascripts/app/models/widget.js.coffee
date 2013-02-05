class App.Models.Widget extends Backbone.Model
  # attributes: position(attributes: x, y) z_order
  @idGenerator = new App.Lib.Counter

  defaults: ->
    position: { x: 1024/4, y: 768/4 }


  initialize: ->
    generator = App.Models.Widget.idGenerator
    if @id?
      generator.check(@id)
    else
      @set id: generator.next()


##
# A 'hotspot' widget, previously named touch zone. It has an associated
# video or sound (which will play when the hotspot is triggered).
#
class App.Models.HotspotWidget extends App.Models.Widget
  # attributes: radius controlRadius action_id video_id sound_id
  MIN_RADIUS: 16

  defaults: ->
    _.extend super, {
      type: 'HotspotWidget'
      radius: 48
      control_radius: 28
    }


##
# A widget that has an associated image.
#
# It belongs to a scene, and it can have a different position or scale in
# each of the keyframes of that scene. SpriteOrientation is the association
# between a SpriteWidget and a Keyframe; it stores the position and scale of the
# SpriteWidget in that Keyframe.
class App.Models.SpriteWidget extends App.Models.Widget
  # attributes: url scale
  defaults: ->
    _.extend super, {
      type: 'SpriteWidget'
      scale: 1
    }

  getOrientationFor: (keyframe) ->
    keyframe.getOrientationFor(@)


  applyOrientationFrom: (keyframe) ->
    orientation = getOrientationFor(keyframe)
    @set
      scale:    orientation.scale
      position: orientation.position


class App.Models.SpriteOrientation extends Backbone.Model
  # attributes: keyframe_id sprite_widget_id position scale
  defaults:
    type: 'SpriteOrientation'


  spriteWidget: ->
    sceneWidgets = @collection.keyframe.scene.widgets
    spriteWidgetId = @get('sprite_widget_id')
    sceneWidgets.find (widget) => widget.id == spriteWidgetId



##
# A button that has two associated images: one for its default state,
# and one for its tapped/clicked state
#
# It has a name, which shows the purpose of the button.
#
# It is added automatically to the main menu scene. It cannot be added from
# the UI.
#
class App.Models.ButtonWidget extends App.Models.SpriteWidget
  # attributes: name selected_url

  defaults: ->
    _.extend super, {
      type: 'ButtonWidget'
    }


  initialize: ->
    super

    @set filename: "#{@get('name')}.png"                 unless @get('filename')?
    @set url:      "/assets/sprites/#{@get('filename')}" unless @get('url')?


##
# A collection of widgets.
# Relations:
# * keyframe - should be set if this collection belongs to a Keyframe
# * scene - should be set if this collection belongs to a Scene
class App.Collections.Widgets extends Backbone.Collection

  model: (attrs, options) ->
    new App.Models[attrs.type](attrs, options)


##
# The collection of widgets that are present for the current keyframe.
# It listens for changes in the current keyframe and updates its contents
# to match what widgets exist for that keyframe, in an efficient manner.
class App.Collections.CurrentWidgets extends App.Collections.Widgets

  initialize: ->
    @currentKeyframe = null

    App.currentSelection.on 'change:keyframe', (__, keyframe) =>
      @changeKeyframe(keyframe)


  changeKeyframe: (keyframe) ->
    @updateSceneWidgets(keyframe)
    @updateKeyframeWidgets(keyframe)

    @_removeListeners(@currentKeyframe)
    @currentKeyframe = keyframe
    @_addListeners(@currentKeyframe)


  updateSceneWidgets: (keyframe) ->
    if @currentKeyframe?
      if @currentKeyframe.scene != keyframe?.scene
        widgets = @currentKeyframe.scene.widgets
        @remove(widgets.models) if widgets?

    widgets = keyframe?.scene.widgets
    @add(widgets.models) if widgets?


  updateKeyframeWidgets: (keyframe) ->
    widgets = @currentKeyframe?.widgets
    @remove(widgets.models) if widgets?

    widgets = keyframe?.widgets
    @add(widgets.models) if widgets?


  _addListeners: (keyframe) ->
    return unless keyframe?

    keyframe.widgets.on 'add',    @add,    @
    keyframe.widgets.on 'remove', @remove, @
    keyframe.scene.widgets.on 'add',    @add,    @
    keyframe.scene.widgets.on 'remove', @remove, @


  _removeListeners: (keyframe) ->
    return unless keyframe?

    keyframe.scene.widgets.off 'add',    @add,    @
    keyframe.scene.widgets.off 'remove', @remove, @
