#= require ./context_menu

class App.Views.ImageWidgetContextMenu extends App.Views.ContextMenu
  CONTROL_KEYS: _.map ['backspace', 'tab', 'enter', 'home', 'end', 'left', 'right'], (name) -> App.Lib.Keycodes[name]

  events: ->
    _.extend {}, super,
      'keydown  #scale-amount':  'enterKeyScaleListener'
      'keyup    #scale-amount':  'scaleAmountUpDownArrow'
      'keypress #scale-amount':  'numericInputListener'
      'click .bring-to-front':   'bringToFront'
      'click .put-in-back':      'putInBack'


  initialize: ->
    super
    @_addListeners()


  remove: ->
    @stopListening()
    super


  scaleAmountUpDownArrow: (event) ->
    _kc = event.keyCode
    if _kc is App.Lib.Keycodes.up
      @_setScale(1)
    if _kc is App.Lib.Keycodes.down
      @_setScale(-1)


  numericInputListener: ->
    number = App.Lib.Keycodes[0] <= event.which <= App.Lib.Keycodes[9]
    ok = not event.which or number or @CONTROL_KEYS.indexOf(event.which) > -1

    event.preventDefault() unless ok


  enterKeyScaleListener: (event) ->
    @_setScale() if event.keyCode is App.Lib.Keycodes.enter


  bringToFront: (e) ->
    App.vent.trigger 'bring_to_front:sprite', @widget


  putInBack: (e) ->
    App.vent.trigger 'put_in_back:sprite', @widget


  _addListeners: ->
    @listenTo App.currentSelection, 'change:keyframe', @_keyframeChanged


  # is overridden
  _keyframeChanged: (keyframe) ->
    @render()


  _setScale: (scale_by) ->
    object = @getModel()
    scale = object.get('scale') * 100
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
    object.set(scale: @_currentScale() / 100)


  _currentScale: ->
    window.parseFloat(@$('#scale-amount').val())


  _scaleCantBeSet: ->
    App.vent.trigger('show:message', 'warning', 'Scale can not be set to less than ten.')
