#= require ./context_menu

class App.Views.ImageWidgetContextMenu extends App.Views.ContextMenu

  events: ->
    _.extend {}, super,
      'keypress #scale-amount':   '_keyPressedInScale'
      'keyup    #scale-amount':   '_keyUpInScale'
      'click    .bring-to-front': 'bringToFront'
      'click    .put-in-back':    'putInBack'


  initialize: ->
    super
    @_addListeners()


  remove: ->
    @_removeCoordinates()
    super


  _keyPressedInScale: (event) ->
    code = event.charCode
    number = App.Lib.CharCodes[0] <= code <= App.Lib.CharCodes[9]
    ok = not event.which or number or event.which is App.Lib.KeyCodes.backspace

    event.preventDefault() unless ok


  _keyUpInScale: (event) ->
    @_scaleAmountUpDownArrow(event)
    @_enterKeyScaleListener(event)


  _scaleAmountUpDownArrow: (event) ->
    code = event.keyCode
    if code is App.Lib.KeyCodes.up
      @_setScale(1)
    if code is App.Lib.KeyCodes.down
      @_setScale(-1)


  _enterKeyScaleListener: (event) ->
    if event.keyCode is App.Lib.KeyCodes.enter
      @_setScale()


  bringToFront: (e) ->
    App.trackUserAction 'Brought image to front'
    App.vent.trigger 'bring_to_front:sprite', @widget


  putInBack: (e) ->
    App.trackUserAction 'Put image in back'
    App.vent.trigger 'put_in_back:sprite', @widget


  _addListeners: ->
    @listenTo App.currentSelection, 'change:keyframe', @_keyframeChanged


  # is overridden
  _keyframeChanged: (keyframe) ->
    @render()


  _setScale: (scale_by) ->
    object = @getModel()
    scale = object.get('scale') * 100

    newScale = if scale_by? then scale + scale_by else parseInt(@_currentScale())
    if newScale < 10
      @_scaleCantBeSet()
      newScale = 10
    else
      App.trackUserAction 'Resized image'

    object.set
      scale: newScale / 100


    @$('#scale-amount').val(newScale)



  _currentScale: ->
    window.parseFloat(@$('#scale-amount').val())


  _scaleCantBeSet: ->
    App.vent.trigger('show:message', 'warning', 'Scale can not be set to less than ten.')
