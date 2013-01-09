class App.Views.TextEditorPalette extends Backbone.View
  template: JST['app/templates/palettes/text_editor']

  events:
    'change .font_face, .font_size ' : 'update'
    'click  .delete'                 : 'destroyKeyframeText'


  render: ->
    @$el.html(@template())
    @


  writeFontFaces: (fonts) ->
    $storybookFontFaces = $('#storybook-font-faces').empty()
    _.each fonts, (f) ->
      fontFace = "@font-face { font-family: '#{f.get('name')}'; src: url('#{f.get('url')}'); }"
      $storybookFontFaces.append(fontFace)


  setFontDefaults: ->
    @fontFace  App.currentScene().get('font_face')
    @fontColor App.currentScene().get('font_color')
    @fontSize  App.currentScene().get('font_size')


  collection: (collection) ->
    if collection then @collection = collection else @collection


  update: ->
    attributes =
      font_color : @fontColor()
      font_face  : @fontFace()
      font_size  : @fontSize()
    App.currentScene().save(attributes)

    $('.text_widget').css
      'font-family' : @fontFace()
      'font-size'   : "#{@fontSize()}px"
      'color'       : @fontColor()


  fontFace: (ff) ->
    if ff then @$('.font_face').val(ff) else @$('.font_face option:selected').val()


  fontSize: (fs)->
    if fs then @$(".font_size").val(fs) else @$('.font_size option:selected').val()


  fontColor: (fc) ->
    if fc then @$('.colorpicker').val(fc) else @$('.colorpicker').val()


  setPosition: (_top, _left) ->
    @$el.css
      top  : _top - (@$el.height() + 20)
      left : _left


  destroyKeyframeText: (e) ->
    $target = $(e.target)
    self = this
    App.currentKeyframeText().destroy
      success: (model, response) ->
        $('#keyframe_text_' + model.id).remove()
