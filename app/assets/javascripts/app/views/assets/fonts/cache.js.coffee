# Cache a collection of fonts by maintaining, for each one
# * a style tag in the head
# * a transparent span with that font
#
# Usage:
    # cache = new App.Views.FontCache
    # $('head').append cache.render().el
class App.Views.FontCache extends Backbone.View
  tagName: 'style'

  render: ->
    @$bodyEl = $('<div class="trigger-cached-font-download" style="position:absolute;top:-50px">').appendTo('body')
    @


  remove: ->
    @$bodyEl.remove()
    super


  setCollection: (fonts) ->
    @_removeListeners()
    @fonts = fonts
    @_addListeners()
    @_cacheAll()


  _addFont: (font) ->
    $fontFaceImportEl = "@font-face { font-family: '#{font.get('name')}'; src: url('#{font.get('url')}'); }"
    @$el.append $fontFaceImportEl

    $span = $("<span style='font-family:#{font.get('name')}'>&nbsp;</span>")
    @$bodyEl.append $span


  _removeFont: (font) ->
    @$el.find("option[value='#{font.get('name')}']").remove()
    # here we should remove it from body as well, but it's not frequent enough to bother


  _addListeners: ->
    @listenTo @fonts, 'add',    @_addFont
    @listenTo @fonts, 'remove', @_removeFont


  _removeListeners: ->
    @stopListening @fonts


  _cacheAll: ->
    @$el.empty()
    @_addFont(font) for font in @fonts.models
