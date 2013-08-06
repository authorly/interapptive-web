# This maintains a style tag in the head with any fonts
# uploaded by user. This way we cache the fonts in the
# browser and when font of a text widget changes, it
# appears visually almost instantaneously.
class App.Views.FontCache extends Backbone.View

  openStorybook: (storybook) ->
    @_removeStorybookListeners()
    @storybook = storybook
    @_addStorybookListeners()
    @_cacheExistingFonts()


  addFontToCache: (font) ->
    return if font.isSystem()

    $fontFaceImportEl = "@font-face { font-family: '#{font.get('name')}'; src: url('#{font.get('url')}'); }"
    @$el.append($fontFaceImportEl)


  removeFontFromCache: (font) ->
    @$el.find("option[value='#{font.get('name')}']").remove()


  _addStorybookListeners: ->
    @storybook.fonts.on 'add',    @addFontToCache,      @
    @storybook.fonts.on 'remove', @removeFontFromCache, @


  _removeStorybookListeners: ->
    return unless @storybook?
    @storybook.fonts.off 'add',    @fontAdded, @
    @storybook.fonts.off 'remove', @removeFontOption, @


  _cacheExistingFonts: ->
    @$el.empty()
    @addFontToCache(font) for font in @storybook.fonts.models
