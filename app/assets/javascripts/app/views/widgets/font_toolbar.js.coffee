class App.Views.FontToolbar extends Backbone.View
  template: JST['app/templates/widgets/font_toolbar']
  className:    'font_toolbar'
  _hidden:      true
  events:
    'change .font_face' : 'update'
    'change .font_size' : 'update'
    'click .close_x'    : 'onCloseClick'
    'click .delete'     : 'destroyKeyframeText'


  initialize: ->
    @render()
    @setDefaults()
    $(@el).find(".colorpicker").miniColors
      change: (hex, rgb) => @update()
    $(@el).draggable()


  render: (model)->
    App.fontsCollection.fetch
      success: =>
        @writeFontFaces(App.fontsCollection.models)
        $(@el).html(@template(fonts: App.fontsCollection.models))
    this


  writeFontFaces: (fonts) ->
    $storybookFontFaces = $('#storybook-font-faces').html('')
    _.each fonts, (f) ->
      fontFace = "@font-face { font-family: '#{f.get('name')}'; src: url('#{f.get('url')}'); }"
      $storybookFontFaces.append(fontFace)


  setDefaults: ->
    @fontFace  App.currentScene().get('font_face')
    @fontColor App.currentScene().get('font_color')
    @fontSize  App.currentScene().get('font_size')


  collection: (collection) ->
    if collection then @collection = collection else @collection


  attachToTextWidget: (textWidget) ->
    @setDefaults()
    @update()
    @setPosition(textWidget.bottom(), textWidget.left())
    @show()


  update: ->
    $('.text_widget').css
      "font-family": @fontFace()
      "font-size":   @fontSize() + "px"
      "color":       @fontColor()

    attributes =
      font_face:  @fontFace()
      font_size:  @fontSize()
      font_color: @fontColor()
    App.currentScene().save attributes


  fontFace: (ff) ->
    if ff then $(@el).find('.font_face').val(ff) else $(@el).find(".font_face option:selected").val()


  fontSize: (fs)->
    if fs then $(@el).find(".font_size").val(fs) else $(@el).find(".font_size option:selected").val()


  fontColor: (fc) ->
    if fc then $(@el).find('.colorpicker').val(fc) else $(@el).find('.colorpicker').val()


  deselectAlignment: ->
    $('.align_button').removeClass('selected')


  show: ()->
    $(@el).show()
    @_hidden = false


  setPosition: (_top, _left) ->
    padding = 20
    $(@el).css
      top : _top - ($(@el).height() + padding)
      left : _left


  onCloseClick: ->
    @hide()
    App.fontToolbarClosed()


  hide: ->
    if !@_mouseEntered
      $(@el).hide()
      @_hidden = true


  destroyKeyframeText: (e) ->
    $target = $(e.target)
    self = this
    App.currentKeyframeText().destroy
      success: (model, response) ->
        $('#keyframe_text_' + model.id).remove()
        self.onCloseClick()
