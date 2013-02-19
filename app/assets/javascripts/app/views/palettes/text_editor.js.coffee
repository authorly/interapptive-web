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


  initialize: ->
    App.vent.on 'scene:active', @changeScene, @
    App.vent.on 'select:font_color', @fontColorSelected, @


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
    @scene.off('change') if @scene
    @scene = model
    @scene.on 'change', -> @.save()

    if @scene.isMainMenu() then @disable() else @enable()

    @setDefaultValsForScene()


  setDefaultValsForScene: ->
    @$('#font-face').val @scene.get('font_face')
    @$('#font-size').val @scene.get('font_size')

    color = @scene.get('font_color')
    r = color.r
    g = color.g
    b = color.b
    @$('#colorpicker span i').css('background-color', "rgb(#{r}, #{g}, #{b})")


  fontFaceChanged: (event) ->
    selectedFontFace = $(event.currentTarget).val()
    @scene.set('font_face', selectedFontFace)

    App.vent.trigger 'change:font_face', selectedFontFace


  fontSizeChanged: (event) ->
    selectedFontSize = $(event.currentTarget).val()
    @scene.set('font_size', selectedFontSize)

    App.vent.trigger 'change:font_size', selectedFontSize


  fontColorSelected: (color) ->
    @scene.set 'font_color',
      r: color.r
      g: color.g
      b: color.b


  cacheUploadedFonts: (fonts) ->
    $storybookFontFaces = $('#storybook-font-faces').empty()
    _.each fonts, (f) ->
      fontFace = "@font-face { font-family: '#{f.get('name')}'; src: url('#{f.get('url')}'); }"
      $storybookFontFaces.append(fontFace)


  disable: ->
    @$('select').attr('readonly', 'readonly')
      .attr('disabled','true')
      .addClass('disabled')
    @$('#colorpicker').addClass('disabled')


  enable: ->
    @$('select').removeAttr('readonly disabled')
      .removeClass('disabled')
    @$('#colorpicker').removeClass('disabled')
