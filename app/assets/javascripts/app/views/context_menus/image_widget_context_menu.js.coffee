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
    unless @_scaleAmountUpDownArrow(event)
      @_setScale()


  _scaleAmountUpDownArrow: (event) ->
    switch event.keyCode
      when App.Lib.KeyCodes.up   then delta =  1
      when App.Lib.KeyCodes.down then delta = -1
      else
        return false
    @_setScale(delta)
    return true


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

    object.set
      scale: newScale / 100


    if parseInt(@$('#scale-amount').val()) != parseInt(newScale)
      @$('#scale-amount').val parseInt(newScale)


  _currentScale: ->
    window.parseFloat(@$('#scale-amount').val())


  _scaleCantBeSet: ->
    App.vent.trigger('show:message', 'warning', 'Scale can not be set to less than ten.')
