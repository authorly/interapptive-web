class App.Views.TextWidgetContextMenu extends App.Views.ContextMenu
  template: JST["app/templates/context_menus/text_widget_context_menu"]

  events: ->
    _.extend {}, super,
      'change #font-face': 'fontFaceChanged'
      'change #font-size': 'fontSizeChanged'
      'click #text-widget-alignment label': 'clickAlignmentOption'


  initialize: ->
    super
    @storybook = @widget.collection.keyframe.scene.storybook


  render: ->
    @$el.html(@template(storybook: @storybook, widget: @widget))

    @initColorPicker()
    @_renderCoordinates @$('#text-widget-coordinates')

    # Following is much easier to do here than in the template
    @$('#font-face').val(@widget.font()?.get('id'))
    @$('#font-size').val(@widget.get('font_size'))
    color = @widget.get('font_color')
    @_setPaletteColor(color)

    id = @$("#text-widget-alignment input[value=#{@widget.get('align')}]").attr('id')
    @$("#text-widget-alignment label[for=#{id}]").addClass 'active'

    @


  initColorPicker: ->
    @rgb = null

    @colorPickerEl = @$('#font-color-selector')
    @colorPickerEl.colorpicker()
      .on('changeColor', (event) =>
        @rgb = event.color.toRGB()
        @_setPaletteColor(@rgb)
        @widget.trigger('change:visual_font_color', @rgb))
      .on('hidePicker', =>
        @fontColorSelected(@rgb))


  fontColorSelected: (color) ->
    return unless color?
    App.trackUserAction 'Changed font color'
    @widget.set('font_color', {r: color.r, g: color.g, b: color.b})


  fontFaceChanged: (event) ->
    App.trackUserAction 'Changed font face'
    font_id = @$('#font-face').val()
    if font_id is 'upload-fonts'
      App.vent.trigger('show:fontLibrary')
    else
      @widget.set(font_id: font_id)


  fontSizeChanged: (event) ->
    App.trackUserAction 'Changed font size'
    font_size = parseInt(@$('#font-size').val())
    @widget.set(font_size: font_size)


  clickAlignmentOption: (event) ->
    label = $(event.currentTarget)
    label.siblings('label').removeClass('active')
    label.addClass 'active'

    input = @$('#' + label.attr('for'))[0]
    input.checked = true
    @widget.set align: input.value



  remove: ->
    @colorPickerEl.colorpicker('hide')
    @colorPickerEl.data('colorpicker').picker.remove()

    @_removeCoordinates()

    super


  _setPaletteColor: (rgb) ->
    @$('#font-color-selector span').css('background-color', "##{App.Lib.ColorHelper.rgbToHex(rgb.r, rgb.g, rgb.b)}")
