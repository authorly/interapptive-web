class App.Views.SpriteEditorPalette extends Backbone.View
  template: JST['app/templates/palettes/sprite_editor']
  tagName:   'form'
  className: 'sprite-editor'
  CONTROL_KEYS: [8, 9, 13, 35, 36, 37, 39]
  TIMER: null

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
    $scale_amount = @$('#scale-amount')
    options =
      disabled: true
      value:    1.0
      min:      0.2
      max:      2.0
      step:     0.01
      slide: (event, ui) =>
        return unless @widget?
        $scale_amount.text(ui.value)
        @getCurrentOrientation().set(scale: ui.value)
      change: (event, ui) =>
        return unless @widget?
        $scale_amount.text(ui.value)
    @$('#scale').slider(options)


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
    switch event.keyCode
      when 37 then @_moveSprite('left',  1)  # Left
      when 38 then @_moveSprite('up',    1)  # Up
      when 39 then @_moveSprite('right', 1)  # Right
      when 40 then @_moveSprite('down',  1)  # Down


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
    @$('#x-coord, #y-coord').keydown (e) => # Submit position on enter key
      if e.keyCode is 13
        @setSpritePosition()


  _addNumericInputListener: ->
    @$('#x-coord, #y-coord').keypress (event) => # Numeric keyboard inputs only
      if not event.which or (49 <= event.which <= 57) or (48 is event.which and $(this).attr('value')) or @CONTROL_KEYS.indexOf(event.which) > -1
        return
      else
        event.preventDefault()


  _addUpDownArrowListeners: ->
    @$('#x-coord').keyup (event) => # Move/position sprite with up/down keyboard arrows
      _kc = event.keyCode

      if _kc == 38
        @_moveSprite('right', 1)

      if _kc == 40
        @_moveSprite('left', 1)

    @$('#y-coord').keyup (event) =>
      _kc = event.keyCode

      if _kc == 38
        @_moveSprite('up', 1)

      if _kc == 40
        @_moveSprite('down', 1)


  _position: ->
    @_point(@$('#x-coord').val(), @$('#y-coord').val())


  _point: (x, y) ->
     new cc.Point(x, y)


  _delayedSavePosition: (point) ->
    console.trace()
    window.clearTimeout(@TIMER)
    @TIMER = window.setTimeout((=> @_setPosition(point)), 400)


  _setPosition: (point) ->
    @getCurrentOrientation().set(position: { x: parseInt(point.x), y: parseInt(point.y) })
