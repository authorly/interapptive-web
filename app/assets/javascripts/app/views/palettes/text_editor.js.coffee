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
    App.vent.on 'activate:TextWidget',   @changeTextWidget,  @
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
    @$('#font-face').val @widget.font_value()
    @$('#font-size').val @widget.get('font_size')


  fontFaceChanged: (event) ->
    $selectedFontFace = $(event.currentTarget)
    if $selectedFontFace.find('option:selected').data('type') is 'system'
      @widget.set
        font_id: null
        font_face: $selectedFontFace.val()
    else
      @widget.set
        font_id: $selectedFontFace.val()
        font_face: null


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
    storybook.fonts.on 'remove', @fontRemoved, @


  _removeFontsListeners: (storybook) ->
    return unless storybook?

    storybook.fonts.off 'add',    @fontAdded, @
    storybook.fonts.off 'remove', @fontRemoved, @


  cacheExistingFonts: ->
    $fontCacheEl = @$('#font-cache')
    $fontCacheEl.empty()

    @fonts = @storybook.fonts.models
    _.each @fonts, (f) =>
      @addFontToCache f.get('name'), f.get('url')


  addFontToCache: (name, url) ->
    $fontFaceImportEl = "@font-face { font-family: '#{name}'; src: url('#{url}'); }"
    @$('#font-cache').append($fontFaceImportEl)


  addFontOption: (name, id) ->
    @noFontsElement().hide()

    $('<option/>',
      value: id
      text:  name
    ).appendTo('#uploaded-fonts')


  removeFontOption: (name) ->
    @noFontsElement().show() if @storybook.fonts.length == 0
    @$("#uploaded-fonts option[value='#{name}']").remove()


  addExistingFontOptions: ->
    return if @fonts.length < 1

    $fontOptionGroupEl = '#uploaded-fonts'
    @$($fontOptionGroupEl).empty()
    @addFontOption(font.get('name'), font.get('id')) for font in @fonts


  fontAdded: (font) ->
    @addFontToCache(font.get('name'), font.get('url'))
    @addFontOption(font.get('name'), font.get('id'))


  fontRemoved: (font) ->
    @removeFontOption font.get('name')


  disable: =>
    @_unsetCurrentWidget()
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


  # Manually unsetting the text widget so that next time when
  # App.currentSelection.set('widget', <a-text-widget>) fires 
  # 'change:widget' event (that is translated to 'activate:TextWidget')
  # if same text widget is selected, unselected and selected again.
  _unsetCurrentWidget: ->
    App.currentSelection.set('widget', null)
