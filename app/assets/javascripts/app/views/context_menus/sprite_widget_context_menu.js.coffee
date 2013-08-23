#= require ./image_widget_context_menu

class App.Views.SpriteWidgetContextMenu extends App.Views.ImageWidgetContextMenu

  events: ->
    _.extend({}, super, {
      'click .remove': 'deleteSprite'
    })

  template: JST["app/templates/context_menus/sprite_widget_context_menu"]


  _render: ->
    @$el.html(@template(filename: @widget.filename(), orientation: @getCurrentOrientation()))
    @


  getCurrentOrientation: ->
    @_currentOrientation ||= @widget.getOrientationFor(App.currentSelection.get('keyframe'))


  deleteSprite: (e) ->
    e.stopPropagation()
    @widget.collection.remove(@widget) if @widget.collection


  _moveSprite: (direction, pixels) ->
    current_orientation = @getCurrentOrientation()
    x_oord = current_orientation.get('position').x
    y_oord = current_orientation.get('position').y
    point = @_measurePoint(direction, pixels, x_oord, y_oord)

    @_delayedSavePosition(point) if point?


  _setPosition: (point) ->
    @_setObjectPosition(@getCurrentOrientation(), point)


  _setScale: (scale_by) =>
    @_setObjectScale(@getCurrentOrientation(), scale_by)
