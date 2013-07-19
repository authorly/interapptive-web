##
# A view that displays a collection of assets as a list.
# It allows filtering and searching through the collection.
#
class App.Views.AssetLibrarySidebar extends Backbone.View
  template: JST['app/templates/assets/library_sidebar']

  initialize: ->
    @render()
    @adjustSize()
    @initResizable()

    App.vent.on 'window:resize', @adjustSize, @


  render: ->
    @$el.html(@template())
    @


  initResizable: ->
    @$el.parent().resizable
      alsoResize:  '#asset-library-sidebar, #asset-sidebar-sticky-footer, #asset-search-field'
      maxWidth:    500
      minWidth:    320
      handles:     'w'


  adjustSize: ->
    $('#asset-library-sidebar').css height: "#{$(window).height() - 128}px"
    offset = @$el.offset()?.top || 128
    @$el.css height: "#{$(window).height() - offset}px"
