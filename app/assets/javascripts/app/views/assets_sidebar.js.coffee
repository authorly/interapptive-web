class App.Views.AssetsSidebar extends Backbone.View


  initialize: ->
    @adjustSize()
    @initResizable()

    App.vent.on 'window:resize', @adjustSize, @
    App.currentSelection.on 'change:assets', (__, assets) => @assets.setAssets(assets)
    App.currentSelection.on 'change:scene', (__, scene) => @sceneAssets.setCollection(scene.widgets)


  render: ->
    @assets = new App.Views.AssetLibrarySidebar
      el: @$('#asset-library-sidebar')
    @assets.render()
    @_addCollapsibleListeners(@assets.$el)
    @assets.$('#asset-sidebar-sticky-footer input').on 'focus, click', =>
      @$('#asset-library-sidebar').collapse('show')

    @sceneAssets = new App.Views.SpriteList
      el: @$('#sprite-list')
    @sceneAssets.render()
    @_addCollapsibleListeners(@sceneAssets.$el)
    @_revealImagesOnScroll()
    @$('section.active .collapse').collapse('show')


  initResizable: ->
    @$el.resizable
      # alsoResize:  '#asset-library-sidebar, #asset-sidebar-sticky-footer, #asset-search-field'
      alsoResize:  '#asset-sidebar-sticky-footer'
      maxWidth:    500
      minWidth:    305
      handles:     'w'


  adjustSize: ->
    offset = @$el.offset()?.top || 128
    @$el.css height: "#{$(window).height() - offset}px"


  _revealImagesOnScroll: ->
    @$el.scroll ->
      # unveil method is provided by jquery.unveil.js
      # Used to lazily load images in the sidebar.
      # See templates/assets/library/asset.jst.hamlc for data-src
      $('#asset-list-thumb-view img').unveil()
      $('#asset-list-table img').unveil()


  _addCollapsibleListeners: (el) ->
    el.on 'show.bs.collapse hide.bs.collapse', (event) ->
      event.stopPropagation()

      container = $(@).closest('section')
      if event.type == 'show'
        container.addClass('active')
      else
        container.removeClass('active')
