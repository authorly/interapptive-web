class App.Views.SpriteEditorPalette extends Backbone.View
  template: JST['app/templates/palettes/sprite_editor']

  initialize: ->
    @_widget =     null
    @_xEl =        '#x-coord'
    @_yEl =        '#y-coord'
    @_formWindow = '#sprite-editor-palette'

    App.vent.on 'widget:remove', @resetForm


  render: ->
    $(@_formWindow).html(@template())

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
        return unless @_widget?
        $("#scale-amount").text(ui.value)
        @_widget.setScale ui.value

      change: (event, ui) =>
        return unless @_widget?

        $("#scale-amount").text(ui.value)

        @_widget.setScale ui.value
        @_widget.trigger('change', 'scale')

        #
        # RFCTR:
        #     Needs ventilations
        #
        # App.storybookJSON.updateSprite(App.currentScene(), App.builder.widgetLayer.getWidgetById(@getWidget().id))

    @$('#scale').slider(options)


  setSpritePosition: ->
    @_widget.setPosition(new cc.Point $(@_xCoordEl).val(), $(@_yCoordEl).val())


  updateXYFormVals: (touch) ->
    return unless @_widget and App.builder.widgetLayer.hasCapturedWidget()

    $(@_xEl).val(parseInt(@_widget.getPositionX()))
    $(@_yEl).val(parseInt(@_widget.getPositionY()))


  resetForm: =>
    @_widget = null

    $("#{@_xEl}, #{@_yEl}").val(0)

    @clearFilename()
    @disableFields()


  setActiveSprite: (spriteWidget) ->
    return unless spriteWidget
    @_widget = spriteWidget

    xCoord =   parseInt(@_widget.getPositionX())
    yCoord =   parseInt(@_widget.getPositionY())

    $('#sprite-editor-palette').find('.disabled').removeClass 'disabled'

    $(@_xEl).val(xCoord)
    $(@_yEl).val(yCoord)
    @$('#scale').slider 'value', @_widget.getScale()

    @displayFilename()
    @enableFields()


  disableFields: ->
    @$('#scale').slider(disabled: true).slider('value', 1.0)
    $("#{@_xEl}, #{@_yEl}").attr('disabled', true)

    @$el.parent().find('label, span').addClass('disabled')


  enableFields: ->
    @$('#scale').slider disabled: false

    $("#{@_xEl}, #{@_yEl}").attr('disabled', false)


  displayFilename: ->
    $(@_formWindow).
      find('#sprite-filename').
      text(@_widget.getFilename()).
      attr('title', @_widget.getFilename()).
      attr('data-original-title', @_widget.getFilename()).
      tooltip(placement: 'left')


  clearFilename: ->
    $(@_formWindow).
      find('#sprite-filename').
      text('No image selected.').
      tooltip('destroy')


  addEnterKeyInputListener: ->
    $("#{@_xEl}, #{@_yEl}").keydown (e) => # Submit position on enter key
      if e.keyCode is 13
        @_widget.setPosition(new cc.Point $(@_xEl).val(), $(@_yEl).val())


  addNumericInputListener: ->
    $("#{@_xEl}, #{@_yEl}").keypress (event) -> # Numeric keyboard inputs only
      controlKeys = [8, 9, 13, 35, 36, 37, 39]
      isControlKey = controlKeys.join(",").match(new RegExp(event.which))

      if not event.which or (49 <= event.which and event.which <= 57) or (48 is event.which and $(this).attr("value")) or isControlKey
        return
      else
        event.preventDefault()


  addUpDownArrowListeners: =>
    $(@_xEl).keydown (event) => # Move/position sprite with up/down keyboard arrows
      _kc = event.keyCode
      if _kc == 38
        $(@_xEl).val(parseInt(@_widget.getPositionX())+1)
        @_widget.setPosition(new cc.Point(@_widget.getPositionX()+1, @_widget.getPositionY()))
      if _kc == 40
        $(@_xEl).val(parseInt(@_widget.getPositionX())-1)
        @_widget.setPosition(new cc.Point(@_widget.getPositionX()-1, @_widget.getPositionY()))

    $(@_yEl).keydown (event) =>
      _kc = event.keyCode
      if _kc == 38
        $(@_yEl).val(parseInt(@_widget.getPositionY())+1)
        @_widget.setPosition(new cc.Point(@_widget.getPositionX(), @_widget.getPositionY()+1))
      if _kc == 40
        $(@_yEl).val(parseInt(@_widget.getPositionY())-1)
        @_widget.setPosition(new cc.Point(@_widget.getPositionX(), @_widget.getPositionY()-1))
