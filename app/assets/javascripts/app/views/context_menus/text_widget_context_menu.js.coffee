class App.Views.TextWidgetContextMenu extends App.Views.ContextMenu
  template: JST["app/templates/context_menus/text_widget_context_menu"]

  events: ->
    _.extend {}, super,
      'change #font-face':           'fontFaceChanged'
      'change #font-size':           'fontSizeChanged'


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
    @$('#font-color-selector span i').css('background-color', "rgb(#{color.r}, #{color.g}, #{color.b})")
    @


  initColorPicker: ->
    @rgb = null

    @colorPickerEl = @$('#font-color-selector')
    @colorPickerEl.colorpicker()
      .on('changeColor', (event) =>
        @rgb = event.color.toRGB()
        @widget.trigger('change:visual_font_color', @rgb))
      .on('hide', =>
        @fontColorSelected(@rgb))


  fontColorSelected: (color) ->
    return unless color?
    @widget.set('font_color', {r: color.r, g: color.g, b: color.b})


  fontFaceChanged: (event) ->
    font_id = @$('#font-face').val()
    if font_id is 'upload-fonts'
      App.vent.trigger('show:fontLibrary')
    else
      @widget.set(font_id: font_id)


  fontSizeChanged: (event) ->
    font_size = parseInt(@$('#font-size').val())
    @widget.set(font_size: font_size)


  remove: ->
    @colorPickerEl.colorpicker('hide')
    @colorPickerEl.data('colorpicker').picker.remove()

    @_removeCoordinates()

    super

