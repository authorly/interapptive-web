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
    App.vent.on 'opened:storybook',  @openedStorybook,   @
    App.vent.on 'select:font_color', @fontColorSelected, @
    App.vent.on 'uploaded:fonts',    @fontsUploaded, @
    App.vent.on 'activate:scene',    @changeScene,   @
    # App.vent.on 'destroyed:font',  @fontDestroyed, @
    App.vent.on 'edit:text_widget',  @disable
    App.vent.on 'done_editing:text', @enable


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
      App.vent.trigger 'change:font_color', @rgb
    ).on('hide', =>
      App.vent.trigger 'select:font_color', @rgb
    )


  changeScene: (model) ->
    @scene = model
    if @scene.isMainMenu() then @disable() else @enable()

    @setDefaultValsForScene()


  setDefaultValsForScene: ->
    color = @scene.get('font_color')
    rgb = [color.r,color.g,color.b]
    @$('#colorpicker span i').css('background-color', "rgb(#{rgb[0]}, #{rgb[1]}, #{rgb[2]})")
    @$('#font-face').val @scene.get('font_face')
    @$('#font-size').val @scene.get('font_size')


  fontFaceChanged: (event) ->
    selectedFontFace = $(event.currentTarget).val()
    @scene.set('font_face', selectedFontFace)

    App.vent.trigger 'change:font_face', selectedFontFace


  fontSizeChanged: (event) ->
    selectedFontSize = $(event.currentTarget).val()
    @scene.set('font_size', selectedFontSize)

    App.vent.trigger 'change:font_size', selectedFontSize


  fontColorSelected: (color) ->
    @scene = App.currentSelection.get('scene')
    @scene.set 'font_color',
      r: color.r
      g: color.g
      b: color.b


  openedStorybook: (storybook) ->
    @storybook = storybook
    @cacheExistingFonts()
    @addExistingFontOptions()


  cacheExistingFonts: ->
    $fontCacheEl = @$('#font-cache')
    $fontCacheEl.empty()

    @fonts = @storybook.fonts.models
    _.each @fonts, (f) =>
      @addFontToCache f.get('name'), f.get('url')


  addFontToCache: (name, url) ->
    $fontFaceImportEl = "@font-face { font-family: '#{name}'; src: url('#{url}'); }"
    @$('#font-cache').append($fontFaceImportEl)


  addFontOption: (name) ->
    $('<option/>',
      value: name
      text:  name
    ).appendTo('#uploaded-fonts')


  addExistingFontOptions: ->
    return if @fonts < 1

    $fontOptionGroupEl = '#uploaded-fonts'
    @$($fontOptionGroupEl).empty()
    @addFontOption(font.get('name')) for font in @fonts


  fontsUploaded: (fonts) ->
    @addFontToCache(font.name, font.url) for font in fonts
    @addFontOption(font.name) for font in fonts


  # fontDestroyed: (font) ->
  #   console.log "destroyed font: ", font
  #   console.log "destroyed JSON.parse(font): ", JSON.parse(font)


  disable: =>
    @$('select').attr('readonly', 'readonly')
      .attr('disabled','true')
      .addClass('disabled')
    @$('#colorpicker').addClass('disabled')
      .find('span i')
      .css('background-color', 'rgb(0, 0, 0)')


  enable: =>
    color = @scene.get('font_color')
    @$('select').removeAttr('readonly disabled')
      .removeClass('disabled')
    @$('#colorpicker').removeClass('disabled')
    @$('#colorpicker span i').css("background-color", "rgb(#{color.r}, #{color.g}, #{color.b})")
