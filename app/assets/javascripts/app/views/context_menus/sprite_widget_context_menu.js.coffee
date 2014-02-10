#= require ./image_widget_context_menu

class App.Views.SpriteWidgetContextMenu extends App.Views.ImageWidgetContextMenu

  events: ->
    _.extend {}, super, {
      'click .as-previous': 'asPreviousKeyframe'
      'click .as-next':     'asNextKeyframe'
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
    if @orientation?
      html = @template
        filename: @widget.filename()
        orientation: @orientation
      @$el.html html
      @_renderCoordinates @$('#sprite-coordinates')
    else
      @$el.empty()

    @


  remove: ->
    @_removeCoordinates()
    super


  getModel: ->
    @orientation


  asPreviousKeyframe: (e) ->
    @widget.asPreviousKeyframe App.currentSelection.get('keyframe')


  asNextKeyframe: (e) ->
    @widget.asNextKeyframe App.currentSelection.get('keyframe')
