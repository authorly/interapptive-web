class App.Views.FontToolbar extends Backbone.View
  template: JST['app/templates/widgets/font_toolbar']

  className: 'font_toolbar'

  events:
    'change .font_face, .font_size ' : 'update'
    'click  .close_x'                : 'onCloseClick'
    'click  .delete'                 : 'destroyKeyframeText'


  initialize: ->
    @render()

    @setFontDefaults()

    @$('.colorpicker').miniColors change: (hex, rgb) => @update()

    @$el.draggable()

    App.vent.on 'text_widget:done_editing', => @active = false
    App.vent.on 'text_widget:edit'        ,    @attachToTextWidget

    @_hidden = true


  render: (model) =>
    App.fontsCollection.fetch
      success: =>
        @writeFontFaces App.fontsCollection.models
        @$el.html @template(fonts: App.fontsCollection.models)

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


  attachToTextWidget: (widget) =>
    @setDefaults()
    @update()
    @setPosition widget.bottom(), widget.left()
    @show()


  setDefaults: ->
    @fontFace  App.currentScene().get('font_face')
    @fontColor App.currentScene().get('font_color')
    @fontSize  App.currentScene().get('font_size')


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


  onCloseClick: ->
    @hide()
    App.fontToolbarClosed()


  show: ()->
    @$el.show()
    @_hidden = false


  hide: ->
    return unless @_mouseEntered
    @$el.hide()
    @_hidden = true


  destroyKeyframeText: (e) ->
    $target = $(e.target)
    self = this
    App.currentKeyframeText().destroy
      success: (model, response) ->
        $('#keyframe_text_' + model.id).remove()
        self.onCloseClick()
