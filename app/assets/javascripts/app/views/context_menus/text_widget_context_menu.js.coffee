class App.Views.TextWidgetContextMenu extends Backbone.View
  events:
    'change #font-face':           'fontFaceChanged'
    'change #font-size':           'fontSizeChanged'
    'click  #font-face-selector':  'fontFaceSelectorClicked'
    'click  #font-size-selector':  'fontSizeSelectorClicked'
    'click  #font-color-selector': 'fontColorSelectorClicked'
    'click  .remove':              'delete'

  template: JST["app/templates/context_menus/text_widget_context_menu"]

  initialize: ->
    @widget = @options.widget
    @storybook = @widget.collection.keyframe.scene.storybook


  render: ->
    @$el.html(@template(storybook: @storybook, widget: @widget))
    @initColorPicker()

    # Following is much easier to do here than in the template
    @$('#font-face').val(@widget.font()?.get('id'))
    @$('#font-size').val(@widget.get('font_size'))
    color = @widget.get('font_color')
    @$('#font-color-selector span i').css('background-color', "rgb(#{color.r}, #{color.g}, #{color.b})")
    @


  fontFaceSelectorClicked: (event) ->
    # Stop the event, so the text widget stays in context
    event.stopPropagation()


  fontSizeSelectorClicked: (event) ->
    # Stop the event, so the text widget stays in context
    event.stopPropagation()


  fontColorSelectorClicked: (event) ->
    # Stop the event, so the text widget stays in context
    event.stopPropagation()


  initColorPicker: ->
    @rgb = null

    colorPickerEl = @$('#font-color-selector')
    colorPickerEl.colorpicker()
      .on('changeColor', (event) =>
        @rgb = event.color.toRGB()
        @widget.trigger('change:visual_font_color', @rgb))
      .on('hide', =>
        @fontColorSelected(@rgb))


  fontColorSelected: (color) ->
    @widget.set('font_color', {r: color.r, g: color.g, b: color.b})


  fontFaceChanged: (event) ->
    font_id = @$('#font-face').val()
    if font_id is 'upload-fonts'
      App.vent.trigger('show:fontLibrary')
    else
      event.stopPropagation()
      @widget.set(font_id: font_id)


  fontSizeChanged: (event) ->
    event.stopPropagation()
    font_size = @$('#font-size').val()
    @widget.set(font_size: font_size)


  delete: (event) ->
    event.stopPropagation()
    @widget.collection?.remove(@widget)
