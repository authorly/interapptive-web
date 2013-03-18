class App.Views.SpriteEditorPalette extends Backbone.View
  template:  JST['app/templates/palettes/sprite_editor']

  tagName:   'form'

  className: 'sprite-editor'

  POSITION_TIMER: null

  SLIDER_DEFAULT: 1.0
  SLIDER_STEP:    0.01
  SLIDER_MIN:     0.2
  SLIDER_MAX:     2.0

  ENTER_KEYCODE: 13
  LEFT_KEYCODE:  37
  UP_KEYCODE:    38
  RIGHT_KEYCODE: 39
  DOWN_KEYCODE:  40
  CONTROL_KEYS: [8, 9, @ENTER_KEYCODE, 35, 36, @LEFT_KEYCODE, @RIGHT_KEYCODE]


  initialize: ->
    App.currentSelection.on 'change:widget', @setActiveSprite, @


  render: ->
    @$el.html(@template())
    @_initScaleSlider()
    @_addCoordinatesListeners()
    @


  _addCoordinatesListeners: ->
    @_addClickListener()
    @_addUpDownArrowListeners()
    @_addNumericInputListener()
    @_addEnterKeyInputListener()


  _initScaleSlider: ->
    @$('#scale').slider(@_sliderOptions())


  _sliderOptions: ->
    options =
      disabled: true
      value:    @SLIDER_DEFAULT
      step:     @SLIDER_STEP
      min:      @SLIDER_MIN
      max:      @SLIDER_MAX
      stop:     @_setScale
      slide:    @_propagateSlide
      change:   @_setScaleOnSpriteElement


  getCurrentOrientation: ->
    @widget.getOrientationFor(App.currentSelection.get('keyframe'))


  setSpritePosition: ->
    @_delayedSavePosition(@_position())


  resetForm: =>
    @widget = null

    @$('#x-coord, #y-coord').val(0)

    @clearFilename()
    @disableFields()


  setActiveSprite: (__, sprite) ->
    return unless sprite instanceof App.Models.SpriteWidget

    if sprite
      @widget = sprite
      @enablePalette()
      @displayFilename()
      @enableFields()
      $('body').on('keyup', @_moveSpriteWithArrows)
      @widget.on('move', @changeCoordinates, @)

    else
      @widget.off('move', @changeCoordinates, @) if @widget?
      $('body').off('keyup', @_moveSpriteWithArrows)
      @resetForm()


  enablePalette: ->
    @$('.disabled').removeClass('disabled')

    current_orientation = @getCurrentOrientation()
    @$('#x-coord').val(parseInt(current_orientation.get('position').x))
    @$('#y-coord').val(parseInt(current_orientation.get('position').y))
    @$('#scale').slider('value', current_orientation.get('scale'))


  disableFields: ->
    @$('#scale').slider(disabled: true).slider('value', 1.0)
    @$('#x-coord, #y-coord').attr('disabled', true)


  enableFields: ->
    @$('#scale').slider disabled: false
    @$('#x-coord, #y-coord').attr 'disabled', false


  displayFilename: ->
    filename = @widget.get('filename')
    @$('#sprite-filename')
     .text(filename)
     .attr('title', filename)
     .attr('data-original-title', filename)
     .tooltip(placement: 'left')


  clearFilename: ->
    @$('#sprite-filename')
     .text('No image selected.')
     .tooltip('destroy')


  changeCoordinates: (new_point) ->
    return unless new_point?
    @$('#x-coord').val(parseInt(new_point.x))
    @$('#y-coord').val(parseInt(new_point.x))
    @setSpritePosition()


  _moveSpriteWithArrows: (event) =>
    return unless @$('li.half').find('input').attr('disabled') is 'disabled'

    switch event.keyCode
      when @LEFT_KEYCODE  then @_moveSprite('left',  1)
      when @UP_KEYCODE    then @_moveSprite('up',    1)
      when @RIGHT_KEYCODE then @_moveSprite('right', 1)
      when @DOWN_KEYCODE  then @_moveSprite('down',  1)


  _moveSprite: (direction, pixels) ->
    current_orientation = @getCurrentOrientation()
    x_oord = current_orientation.get('position').x
    y_oord = current_orientation.get('position').y
    point  = null

    switch direction
      when 'left'
        @$('#x-coord').val(parseInt(x_oord) - pixels)
        point = @_point(x_oord - pixels, y_oord)

      when 'up'
        @$('#y-coord').val(parseInt(y_oord) + pixels)
        point = @_point(x_oord, y_oord + pixels)

      when 'right'
        @$('#x-coord').val(parseInt(x_oord) + pixels)
        point = @_point(x_oord + pixels, y_oord)

      when 'down'
        @$('#y-coord').val(parseInt(y_oord) - pixels)
        point = @_point(x_oord, y_oord - pixels)

    @_delayedSavePosition(point) if point?


  _addClickListener: ->
    @$('li.half').find('label, input').click (event) ->
      event.stopPropagation()


  _addEnterKeyInputListener: ->
    @$('#x-coord, #y-coord').keydown (e) =>
      @setSpritePosition() if e.keyCode is @ENTER_KEYCODE


  _addNumericInputListener: ->
    @$('#x-coord, #y-coord').keypress (event) => # Numeric keyboard inputs only
      if not event.which or (48 <= event.which <= 57) or (48 is event.which and $(this).attr('value')) or @CONTROL_KEYS.indexOf(event.which) > -1
        return
      else
        event.preventDefault()


  _addUpDownArrowListeners: ->
    @$('#x-coord').keyup (event) =>
      _kc = event.keyCode

      if _kc is @UP_KEYCODE
        @_moveSprite('right', 1)

      if _kc is @DOWN_KEYCODE
        @_moveSprite('left', 1)

    @$('#y-coord').keyup (event) =>
      _kc = event.keyCode

      if _kc is @UP_KEYCODE
        @_moveSprite('up', 1)

      if _kc is @DOWN_KEYCODE
        @_moveSprite('down', 1)


  _position: ->
    @_point(@$('#x-coord').val(), @$('#y-coord').val())


  _point: (x, y) ->
     new cc.Point(x, y)


  _delayedSavePosition: (point) ->
    window.clearTimeout(@POSITION_TIMER)
    @POSITION_TIMER = window.setTimeout((=> @_setPosition(point)), 400)


  _setPosition: (point) ->
    @getCurrentOrientation().set(position: { x: parseInt(point.x), y: parseInt(point.y) })


  _scaleElement: ->
    @$('#scale-amount')


  _setScale: (event, ui) =>
    return unless @widget?
    @_scaleElement().text(ui.value)
    @getCurrentOrientation().set(scale: ui.value)


  _propagateSlide: (event, ui) =>
    return unless @widget?
    @_scaleElement().text(ui.value)
    data =
      model: @widget
      scale: ui.value
    App.vent.trigger 'scale:sprite_widget', data


  _setScaleOnSpriteElement: (event, ui) =>
    return unless @widget?
    @_scaleElement().text(ui.value)
