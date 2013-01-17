class App.Models.Widget extends Backbone.Model
  # attributes: position z_order
  @idGenerator = new App.Lib.Counter


##
# A 'hotspot' widget, previously named touch zone. It has an associated
# video or sound (which will play when the hotspot is triggered).
#
class App.Models.HotspotWidget extends App.Models.Widget
  # attributes: radius controlRadius position{x, y} action_id video_id sound_id

  defaults:
    type: 'HotspotWidget'
    radius: 48
    control_radius: 28


class App.Models.SpriteWidget extends App.Models.Widget
  # attributes: url scale

  getOrientationFor: (keyframe) ->
    keyframe.getOrientationForWidget(@)


  applyOrientationFrom: (keyframe) ->
    orientation = getOrientationFor(keyframe)
    @set
      scale:    orientation.scale
      position: orientation.position


class App.Models.SpriteOrientationWidget extends App.Models.Widget
  # attributes: position scale keyframe_id sprite_widget_id


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

  defaults:
    type: 'ButtonWidget'


  initialize: ->
    @set filename: "#{@get('name')}.png"                 unless @get('filename')?
    @set url:      "/assets/sprites/#{@get('filename')}" unless @get('url')?


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
      @updateKeyframeWidgets(keyframe)
      @updateSceneWidgets(keyframe)

      @currentKeyframe = keyframe


  updateKeyframeWidgets: (keyframe) ->
    # remove old keyframe widgets
    removals = @currentKeyframe?.widgets
    if removals?
      removals.each (widget) => @remove(widget)

    # add new keyframe widgets
    additions = keyframe?.widgets
    if additions?
      additions.each (widget) => @add(widget)


  updateSceneWidgets: (keyframe) ->
    if @currentKeyframe? and @currentKeyframe.scene != keyframe?.scene
      # remove the widgets from the previous scene
      @currentKeyframe.scene.widgets.each (widget) => @remove(widget)

    widgets = keyframe?.scene.widgets
    return unless widgets?

    widgets.each (widget) =>
      if @get(widget)?
        if widget instanceof App.Models.SpriteWidget
          widget.applyOrientationFrom keyframe
      else
        @add(widget)
