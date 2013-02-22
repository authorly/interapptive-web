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

    @initScaleSlider()
    @addUpDownArrowListeners()
    @addNumericInputListener()
    @addEnterKeyInputListener()

    @


  initScaleSlider: ->
    $scale_amount = @$('scale-amount')
    options =
      disabled: true
      value:    1.0
      min:      0.2
      max:      2.0
      step:     0.01
      slide: (event, ui) =>
        return unless @widget?
        $scale_amount.text(ui.value)
        @widget.set(scale: ui.value)
      change: (event, ui) =>
        return unless @widget?
        $scale_amount.text(ui.value)
    @$('#scale').slider(options)


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

      @$('.disabled').removeClass 'disabled'
      @$('#x-coord').val parseInt(@widget.get('position').x)
      @$('#y-coord').val parseInt(@widget.get('position').y)
      @$('#scale').slider 'value', @widget.get('scale')

      @displayFilename()
      @enableFields()
    else
      @resetForm()


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


  addEnterKeyInputListener: ->
    @$('#x-coord, #y-coord').keydown (e) => # Submit position on enter key
      if e.keyCode is 13
        @setSpritePosition()


  addNumericInputListener: ->
    @$('#x-coord, #y-coord').keypress (event) -> # Numeric keyboard inputs only
      if not event.which or (49 <= event.which and event.which <= 57) or (48 is event.which and $(this).attr('value')) or @CONTROL_KEYS.indexOf(event.which) > -1
        return
      else
        event.preventDefault()


  addUpDownArrowListeners: =>
    @$('#x-coord').keyup (event) => # Move/position sprite with up/down keyboard arrows
      _kc = event.keyCode
      x_oord = @widget.get('position').x
      y_oord = @widget.get('position').y

      if _kc == 38
        @$('#x-coord').val(parseInt(x_oord) + 1)
        point = @_point(x_oord + 1, y_oord)

      if _kc == 40
        @$('#x-coord').val(parseInt(x_oord) - 1)
        point = @_point(x_oord - 1, y_oord)

      @_delayedSavePosition(point) if point?

    @$('#y-coord').keyup (event) =>
      _kc = event.keyCode
      x_oord = @widget.get('position').x
      y_oord = @widget.get('position').y

      if _kc == 38
        @$('#y-coord').val(parseInt(y_oord) + 1)
        point = @_point(x_oord, y_oord + 1)

      if _kc == 40
        @$('#y-coord').val(parseInt(y_oord) - 1)
        point = @_point(x_oord, y_oord - 1)

      @_delayedSavePosition(point) if point?


  _position: ->
    @_point(@$('#x-coord').val(), @$('#y-coord').val())


  _point: (x, y) ->
     new cc.Point(x, y)


  _delayedSavePosition: (point) ->
    window.clearTimeout(@TIMER)
    @TIMER = window.setTimeout((=> @_setPosition(point)), 400)


  _setPosition: (point) ->
    @widget.set(position: { x: point.x, y: point.y })
