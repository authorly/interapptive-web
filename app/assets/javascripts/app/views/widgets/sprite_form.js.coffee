class App.Views.SpriteForm extends Backbone.View
  template: JST['app/templates/widgets/sprite_form']

  initialize: ->
    @_widget =     null
    @_xEl =        '#x-coord'
    @_yEl =        '#y-coord'
    @_scaleEl =    '#scale'
    @_formWindow = '#sprite-form-window'


  render: ->
    $(@_formWindow).html(@template())

    @initScaleSlider()

    @addListeners()

    this


  initScaleSlider: ->
    options = {
      value: 1.0
      min:   0.2
      max:   2.0
      step:  0.01
      disabled: true

      slide: (event, ui) =>
        return unless @getWidget()?
        $("#scale-amount").text(ui.value)
        @getWidget().setScale ui.value

      change: (event, ui) =>
        return unless @getWidget()?
        $("#scale-amount").text(ui.value)
        @getWidget().setScale ui.value
        @getWidget().trigger('change', 'scale')
        App.storybookJSON.updateSprite(App.currentScene(), App.builder.widgetLayer.getWidgetById(@getWidget().id))
    }

    $(@_scaleEl).slider(options)


  getWidget: ->
    @_widget


  addListeners: ->
    @addUpDownArrowListeners()

    @addNumericInputListener()

    @addEnterKeyInputListener()


  setSpritePosition: ->
    @_widget.setPosition(new cc.Point $(@_xCoordEl).val(), $(@_yCoordEl).val())


  updateXYFormVals: (touch) ->
    return unless @_widget and App.builder.widgetLayer.hasCapturedWidget()

    $(@_xEl).val(parseInt(@_widget.getPositionX()))
    $(@_yEl).val(parseInt(@_widget.getPositionY()))


  resetForm: ->
    @_widget = null

    $("#{@_xEl}, #{@_yEl}").val(0)

    @clearFilename()

    @disableFields()


  setActiveSprite: (spriteWidget) ->
    return unless spriteWidget
    @_widget = spriteWidget
    xCoord =   parseInt(@_widget.getPositionX())
    yCoord =   parseInt(@_widget.getPositionY())
    scale =    @_widget.getScale()
    $('#sprite-form-window').find('.disabled').removeClass('disabled')

    $(@_xEl).val(xCoord)
    $(@_yEl).val(yCoord)
    $(@_scaleEl).slider('value', scale)

    @displayFilename()

    @enableFields()


  disableFields: ->
    $(@_rotationEl).slider disabled: true
    $(@_scaleEl).slider disabled: true

    $(@el).parent().find('label, span').addClass('disabled')
    $(@_xEl).attr('disabled', true)
    $(@_yEl).attr('disabled', true)
    $(@_scaleEl).slider('value', 1.0)


  enableFields: ->
    # $(@_rotationEl).slider disabled: false
    $(@_scaleEl).slider disabled: false

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
    xyEls = "#{@_xEl}, #{@_yEl}"

    $(xyEls).keydown (e) => # Submit position on enter key
      if e.keyCode is 13
        @_widget.setPosition(new cc.Point $(@_xEl).val(), $(@_yEl).val())


  addNumericInputListener: ->
    xyEls = "#{@_xEl}, #{@_yEl}"

    $(xyEls).keypress (event) -> # Numeric keyboard inputs only
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



  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
  #                                                                         #
  # TODO:                                                                   #
  #    Finish up rotation, couldn't get shape to match upon rotation        #
  #                                                                         #
  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
  #                                                                         #
  # initRotationSlider: ->                                                  #
  #   options = {                                                           #
  #   value: 0                                                              #
  #   min:   -360                                                           #
  #   max:   360                                                            #
  #   step:  1                                                              #
  #   disabled:  true                                                       #
  #                                                                         #
  #   change: (event, ui) =>                                                #
  #     $("#rotation-amount").text(ui.value)                                #
  #     rotation = $('#rotation-amount').text()                             #
  #     @_widget.setRotatation(rotation)                                    #
  #     this                                                                #
  #   }                                                                     #
  #                                                                         #
  #   $(@_rotationEl).slider(options)                                       #
  #   $(@_rotationEl).slider "option", "disabled", true                     #
  #                                                                         #
  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #


