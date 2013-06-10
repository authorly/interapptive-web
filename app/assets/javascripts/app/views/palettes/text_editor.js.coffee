##
# Text editor / font settings is a UI element for users
# to change the scene's font settings.
# It is applied to each widget in each keyframe,
# but this will soon change.
#
# Has a scene model property which UI changes are applied to.
#
class App.Views.TextEditorPalette extends Backbone.View
  template: JST['app/templates/palettes/text_editor']

  events:
    'change #font-face':  'fontFaceChanged'
    'change #font-size ': 'fontSizeChanged'


  initialize: (options={}) ->
    App.vent.on 'activate:textWidget',   @changeTextWidget,  @
    App.vent.on 'done_editing:text',     @disable,           @


  render: ->
    @$el.html(@template())
    @initColorPicker()
    @


  initColorPicker: ->
    @rgb = null

    colorPickerEl = @$('#colorpicker')
    colorPickerEl.colorpicker().on('show', (event) ->
      if colorPickerEl.hasClass('disabled')
        colorPickerEl.colorpicker('hide')
    ).on('changeColor', (event) =>
      @rgb = event.color.toRGB()
      @widget.trigger('change:visual_font_color', @rgb)
    ).on 'hide', =>
      @fontColorSelected(@rgb)


  changeTextWidget: (widget) ->
    @widget = widget
    @setDefaultValsForTextWidget()
    @enable()


  setDefaultValsForTextWidget: ->
    color = @widget.get('font_color')
    @$('#colorpicker span i').css('background-color', "rgb(#{color.r}, #{color.g}, #{color.b})")
    @$('#font-face').val @widget.font()?.get('id')
    @$('#font-size').val @widget.get('font_size')


  fontFaceChanged: (event) ->
    $selectedFontFace = $(event.currentTarget)
    @widget.set
      font_id: $selectedFontFace.val()


  fontSizeChanged: (event) ->
    selectedFontSize = $(event.currentTarget).val()
    @widget.set('font_size', selectedFontSize)


  fontColorSelected: (color) ->
    @widget.set 'font_color', {r: color.r, g: color.g, b: color.b}


  openStorybook: (storybook) ->
    @_removeFontsListeners(@storybook)
    @_addFontsListeners(storybook)

    @storybook = storybook
    @cacheExistingFonts()
    @addExistingFontOptions()


  _addFontsListeners: (storybook) ->
    return unless storybook?

    storybook.fonts.on 'add',    @fontAdded, @
    storybook.fonts.on 'remove', @removeFontOption, @


  _removeFontsListeners: (storybook) ->
    return unless storybook?

    storybook.fonts.off 'add',    @fontAdded, @
    storybook.fonts.off 'remove', @removeFontOption, @


  cacheExistingFonts: ->
    @$('#font-cache').empty()
    @fonts = @storybook.fonts.models
    @addFontToCache(font) for font in @fonts


  addFontToCache: (font) ->
    return if font.isSystem()

    $fontFaceImportEl = "@font-face { font-family: '#{font.get('name')}'; src: url('#{font.get('url')}'); }"
    @$('#font-cache').append($fontFaceImportEl)


  addFontOption: (font) ->
    $fontEl = $('<option/>',
      value: font.get('id')
      text:  font.get('name')
    )

    if font.isSystem()
      @$('#system-fonts').append($fontEl)
    else
      @noFontsElement().hide()
      @$('#uploaded-fonts').append($fontEl)


  removeFontOption: (font) ->
    @noFontsElement().show() unless @storybook.hasCustomFonts()
    @$("#uploaded-fonts option[value='#{font.get('name')}']").remove()


  addExistingFontOptions: ->
    @$('#uploaded-fonts').empty() if @storybook.hasCustomFonts()
    @addFontOption(font) for font in @fonts


  fontAdded: (font) ->
    @addFontToCache(font)
    @addFontOption(font)


  disable: =>
    @$('select').attr('readonly', 'readonly')
      .attr('disabled','true')
      .addClass('disabled')
    @$('#colorpicker').addClass('disabled')
      .find('span i')
      .css('background-color', 'rgb(0, 0, 0)')


  enable: =>
    color = @widget.get('font_color')
    @$('select').removeAttr('readonly disabled')
      .removeClass('disabled')
    @$('#colorpicker').removeClass('disabled')
    @$('#colorpicker span i').css("background-color", "rgb(#{color.r}, #{color.g}, #{color.b})")


  noFontsElement: ->
    @$('#no-fonts-uploaded')

