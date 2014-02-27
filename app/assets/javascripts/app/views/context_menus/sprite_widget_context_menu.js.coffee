#= require ./image_widget_context_menu

class App.Views.SpriteWidgetContextMenu extends App.Views.ImageWidgetContextMenu

  events: ->
    _.extend {}, super, {
      'click .as-previous': 'asPreviousKeyframe'
      'click .as-next':     'asNextKeyframe'
      'change #image-id':   'imageChanged'
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


  imageChanged: ->
    image_id = @$('#image-id').val()
    @widget.set('image_id', image_id)


  render: ->
    if @orientation?
      html = @template
        filename:    @widget.filename()
        orientation: @orientation
        widget:      @widget
      @$el.html html
      @_renderCoordinates @$('#sprite-coordinates')
    else
      @$el.empty()

    if @$('#image-id').length > 0
      @$('#image-id').val(@widget.get('image_id'))

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
