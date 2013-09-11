#= require ./image_widget_context_menu

class App.Views.SpriteWidgetContextMenu extends App.Views.ImageWidgetContextMenu

  events: ->
    _.extend {}, super, {
      'click .remove':      'deleteSprite'
      'click .as-previous': 'asPreviousKeyframe'
    }

  template: JST["app/templates/context_menus/sprite_widget_context_menu"]


  initialize: (options) ->
    super
    @_setOrientation options.keyframe


  _keyframeChanged: (__, keyframe) ->
    @_setOrientation(keyframe)
    super


  _setOrientation: (keyframe) ->
    @orientation = @widget.getOrientationFor(keyframe)


  render: ->
    html = if @orientation?
      @template
        filename: @widget.filename()
        orientation: @orientation
    else
      ''
    @$el.html(html)

    @



  deleteSprite: (e) ->
    e.stopPropagation()
    @widget.collection.remove(@widget) if @widget.collection


  _moveSprite: (direction, pixels) ->
    x_oord = @orientation.get('position').x
    y_oord = @orientation.get('position').y
    point = @_measurePoint(direction, pixels, x_oord, y_oord)

    @_delayedSavePosition(point) if point?


  _setPosition: (point) ->
    @_setObjectPosition @orientation, point


  _setScale: (scale_by) =>
    @_setObjectScale @orientation, scale_by


  asPreviousKeyframe: (e) ->
    e.stopPropagation()

    @widget.asPreviousKeyframe App.currentSelection.get('keyframe')
