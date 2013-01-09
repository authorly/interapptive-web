class App.Views.SpriteEditorPalette extends Backbone.View
  template:  JST['app/templates/palettes/sprite_editor']

  tagName:   'form'

  className: 'sprite-editor'

  initialize: ->
    App.vent.on 'sprite_widget:deselect widget:remove', @resetForm
    App.vent.on 'sprite_widget:select'                , @setActiveSprite, @


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
        @widget.setScale ui.value

      change: (event, ui) =>
        return unless @widget?
        @$('#scale-amount').text(ui.value)
        console.log "Slide changed, trigger save"
        @widget.changeZOrder(ui.value)

    # RFCTR: Needs ventilation
    # App.storybookJSON.updateSprite(App.currentScene(), App.builder.widgetLayer.getWidgetById(@getWidget().id))

    @$('#scale').slider(options)


  setSpritePosition: ->
    @widget.setPosition(new cc.Point @$('#x-coord').val(), @$('#y-coord').val())


  updateXYFormVals: (touch) ->
    return unless @widget and App.builder.widgetLayer.hasCapturedWidget()

    @$('#x-coord').val(parseInt(@widget.getPositionX()))
    @$('#y-coord').val(parseInt(@widget.getPositionY()))


  resetForm: =>
    @widget = null

    @$('#x-coord, #y-coord').val(0)

    @clearFilename()
    @disableFields()


  setActiveSprite: (spriteWidget) ->
    return unless spriteWidget

    @widget = spriteWidget

    @$('.disabled').removeClass 'disabled'
    @$('#x-coord').val parseInt(@widget.getPositionX())
    @$('#y-coord').val parseInt(@widget.getPositionY())
    @$('#scale').slider 'value', @widget.getScale()

    @displayFilename()
    @enableFields()


  disableFields: ->
    @$('#scale').slider(disabled: true).slider('value', 1.0)
    @$('#x-coord, #y-coord').attr('disabled', true)
    @$el.parent().find('label, span').addClass('disabled')


  enableFields: ->
    @$('#scale').slider disabled: false
    @$('#x-coord, #y-coord').attr 'disabled', false


  displayFilename: ->
    @$('#sprite-filename').
    text(@widget.getFilename()).
    attr('title', @widget.getFilename()).
    attr('data-original-title', @widget.getFilename()).
    tooltip(placement: 'left')


  clearFilename: ->
    @$('#sprite-filename').
      text('No image selected.').
      tooltip('destroy')


  addEnterKeyInputListener: ->
    @$('#x-coord, #y-coord').keydown (e) => # Submit position on enter key
      if e.keyCode is 13
        @widget.setPosition(new cc.Point @$('#x-coord').val(), $('#y-coord').val())


  addNumericInputListener: ->
    @$('#x-coord, #y-coord').keypress (event) -> # Numeric keyboard inputs only
      controlKeys = [8, 9, 13, 35, 36, 37, 39]
      isControlKey = controlKeys.join(",").match(new RegExp(event.which))

      if not event.which or (49 <= event.which and event.which <= 57) or (48 is event.which and $(this).attr('value')) or isControlKey
        return
      else
        event.preventDefault()


  addUpDownArrowListeners: =>
    @$('#x-coord').keydown (event) => # Move/position sprite with up/down keyboard arrows
      _kc = event.keyCode
      if _kc == 38
        @$('#x-coord').val(parseInt(@widget.getPositionX())+1)
        @widget.setPosition(new cc.Point(@widget.getPositionX()+1, @widget.getPositionY()))
      if _kc == 40
        @$('#x-coord').val(parseInt(@widget.getPositionX())-1)
        @widget.setPosition(new cc.Point(@widget.getPositionX()-1, @widget.getPositionY()))

    @$('#y-coord').keydown (event) =>
      _kc = event.keyCode
      if _kc == 38
        @$('#y-coord').val(parseInt(@widget.getPositionY())+1)
        @widget.setPosition(new cc.Point(@widget.getPositionX(), @widget.getPositionY()+1))
      if _kc == 40
        @$('#y-coord').val(parseInt(@widget.getPositionY())-1)
        @widget.setPosition(new cc.Point(@widget.getPositionX(), @widget.getPositionY()-1))
