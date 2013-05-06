class App.Views.SpriteEditorPalette extends Backbone.View
  template:  JST['app/templates/palettes/sprite_editor']

  tagName:   'form'

  className: 'sprite-editor'

  POSITION_TIMER: null

  SCALE_STEP:    1

  ENTER_KEYCODE: 13
  LEFT_KEYCODE:  37
  UP_KEYCODE:    38
  RIGHT_KEYCODE: 39
  DOWN_KEYCODE:  40
  CONTROL_KEYS: [8, 9, @ENTER_KEYCODE, 35, 36, @LEFT_KEYCODE, @RIGHT_KEYCODE]


  initialize: ->
    App.currentSelection.on 'change:widget', @setActiveSprite, @
    App.vent.on 'activate:scene', @resetForm


  render: ->
    @$el.html(@template())
    @_addListeners()
    @


  _addListeners: ->
    @_addClickListener()
    @_addUpDownArrowListeners()
    @_addNumericInputListener()
    @_addEnterKeyInputListener()


  getCurrentOrientation: ->
    @widget.getOrientationFor(App.currentSelection.get('keyframe'))


  resetForm: =>
    @widget = null
    @clearFilename()
    @disableFields()


  setActiveSprite: (__, sprite) ->
    if sprite && sprite instanceof App.Models.SpriteWidget
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
    @$('#scale-amount').val(current_orientation.get('scale') * 100)


  disableFields: ->
    @$('#x-coord, #y-coord, #scale-amount').attr('disabled', true)
    @$('#x-coord, #y-coord').val(0)
    @$('#scale-amount').val(100)


  enableFields: ->
    @$('#x-coord, #y-coord, #scale-amount').attr('disabled', false)


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
    @$('#y-coord').val(parseInt(new_point.y))


  _moveSpriteWithArrows: (event) =>
    return unless @widget?
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
    @$('li').find('label, input').click (event) ->
      event.stopPropagation()


  _addEnterKeyInputListener: ->
    @$('#x-coord, #y-coord').keydown (e) =>
      @_delayedSavePosition(@_position()) if e.keyCode is @ENTER_KEYCODE

    @$('#scale-amount').keydown (e) =>
      @_setScale() if e.keyCode is @ENTER_KEYCODE


  _addNumericInputListener: ->
    @$('#x-coord, #y-coord, #scale-amount').keypress (event) => # Numeric keyboard inputs only
      # 45: -
      # 48: 0
      # 57: 9
      ok = not event.which or (48 <= event.which <= 57) or @CONTROL_KEYS.indexOf(event.which) > -1

      switch event.currentTarget.id
        when 'x-coord', 'y-coord'
          ok = true if event.which == 45

      event.preventDefault() unless ok


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


  _currentScale: ->
    window.parseFloat(@$('#scale-amount').val())


  _setScale: =>
    return unless @widget?
    @getCurrentOrientation().set(scale: @_currentScale() / 100)
