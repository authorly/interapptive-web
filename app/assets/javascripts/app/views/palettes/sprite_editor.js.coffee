class App.Views.SpriteEditorPalette extends Backbone.View
  template: JST['app/templates/palettes/sprite_editor']
  tagName:   'form'
  className: 'sprite-editor'
  CONTROLE_KEYS: [8, 9, 13, 35, 36, 37, 39]

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
    options =
      disabled: true
      value:    1.0
      min:      0.2
      max:      2.0
      step:     0.01
      slide: (event, ui) =>
        return unless @widget?
        @$('#scale-amount').text(ui.value)
        @widget.set(scale: ui.value)
      change: (event, ui) =>
        return unless @widget?
        @$('#scale-amount').text(ui.value)
    @$('#scale').slider(options)


  setSpritePosition: ->
    @widget.set(position: @position())


  updateXYFormVals: (touch) ->
    return unless @widget and App.builder.widgetLayer.hasCapturedWidget()

    @$('#x-coord').val(parseInt(@widget.get('position').x))
    @$('#y-coord').val(parseInt(@widget.get('position').y))


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
    @$el.parent().find('label, span').addClass('disabled')


  enableFields: ->
    @$('#scale').slider disabled: false
    @$('#x-coord, #y-coord').attr 'disabled', false


  displayFilename: ->
    @$('#sprite-filename')
     .text(@widget.get('filename'))
     .attr('title', @widget.get('filename'))
     .attr('data-original-title', @widget.get('filename'))
     .tooltip(placement: 'left')


  clearFilename: ->
    @$('#sprite-filename')
     .text('No image selected.')
     .tooltip('destroy')


  addEnterKeyInputListener: ->
    @$('#x-coord, #y-coord').keydown (e) => # Submit position on enter key
      if e.keyCode is 13
        @widget.set(@_position())


  addNumericInputListener: ->
    @$('#x-coord, #y-coord').keypress (event) -> # Numeric keyboard inputs only
      if not event.which or (49 <= event.which and event.which <= 57) or (48 is event.which and $(this).attr('value')) or @CONTROLE_KEYS.indexOf(event.which) > -1
        return
      else
        event.preventDefault()


  addUpDownArrowListeners: =>
    @$('#x-coord').keydown (event) => # Move/position sprite with up/down keyboard arrows
      _kc = event.keyCode
      if _kc == 38
        @$('#x-coord').val(parseInt(@widget.get('position').x) + 1)
        point = @_point(@widget.get('position').x + 1, @widget.get('position').y)

      if _kc == 40
        @$('#x-coord').val(parseInt(@widget.get('position').x) - 1)
        point = @_point(@widget.get('position').x - 1, @widget.get('position').y)

      @widget.set(position: { x: point.x, y: point.y }) if point?

    @$('#y-coord').keydown (event) =>
      _kc = event.keyCode
      if _kc == 38
        @$('#y-coord').val(parseInt(@widget.get('position').y) + 1)
        point = @_point(@widget.get('position').x, @widget.get('position').y + 1)

      if _kc == 40
        @$('#y-coord').val(parseInt(@widget.get('position').y) - 1)
        point = @_point(@widget.get('position').x, @widget.get('position').y - 1)

      @widget.set(position: { x: point.x, y: point.y }) if point?


  _position: ->
     point = @_point(@$('#x-coord').val(), @$('#y-coord').val())
     console.log(point.x)
     console.log(point.y)
     { x: point.x, y: point.y }


  _point: (x, y) ->
     new cc.Point(x, y)
