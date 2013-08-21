#= require ./image_widget_context_menu

class App.Views.SpriteWidgetContextMenu extends App.Views.ImageWidgetContextMenu

  events: ->
    _.extend({}, super, {
      'click .bring-to-front':                      'bringToFront'
      'click .put-in-back':                         'putInBack'
      'click .remove':                              'deleteSprite'
    })

  template: JST["app/templates/context_menus/sprite_widget_context_menu"]


  _render: ->
    @$el.html(@template(filename: @widget.filename(), orientation: @getCurrentOrientation()))
    @


  getCurrentOrientation: ->
    @widget.getOrientationFor(App.currentSelection.get('keyframe'))


  bringToFront: (e) ->
    e.stopPropagation()
    App.vent.trigger('bring_to_front:sprite', @widget)


  putInBack:(e) ->
    e.stopPropagation()
    App.vent.trigger('put_in_back:sprite', @widget)


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
    @getCurrentOrientation().set(position: { x: parseInt(point.x), y: parseInt(point.y) })


  _setScale: (scale_by) =>
    scale = @getCurrentOrientation().get('scale') * 100
    if scale_by?
      if parseInt(scale) + scale_by < 10
        @_scaleCantBeSet()
        @$('#scale-amount').val(parseInt(scale))
        return
      else
        @$('#scale-amount').val(parseInt(scale) + scale_by)

    else
      if parseInt(@_currentScale()) < 10
        @_scaleCantBeSet()
        @$('#scale-amount').val(parseInt(scale))
        return
    @getCurrentOrientation().set(scale: @_currentScale() / 100)
