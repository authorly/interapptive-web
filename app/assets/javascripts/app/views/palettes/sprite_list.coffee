# Used for the menu for managing the sprites of the current keyframe.
class App.Views.SpriteListPalette extends Backbone.View
  tagName:   'ul'

  className: 'sprites'

  events:
    'click .delete': 'removeSpriteWidget'
    'click li':      'setActiveSpriteWidget'


  render: ->
    @$el.parent().append('<i class="icon-plus icon-black"></i>')

    $('#sprite-list-palette .icon-plus').on 'click', ->
      App.vent.trigger 'add:sprite'

    App.vent.on 'scene:active'       , @removeAll
    App.vent.on 'sprite_widget:add'  , @addSpriteToList
    App.vent.on 'widget:remove'

    @


  setActiveSpriteWidget: (e) ->
    widgetId =       $(e.currentTarget).find('div').attr('data-widget-id')
    activeWidget =   App.builder.widgetLayer.getWidgetById(widgetId)
    return unless activeWidget?

    activeWidget.setAsActive()
    App.builder.widgetLayer.setSelectedWidget(activeWidget)


  addSpriteToList: (widget) =>
    return unless widget.sprite

    view = new App.Views.SpriteWidget(widget: widget)
    @$el.prepend(view.render().el)

    widget.on 'change', (what) ->
      view.render() if what == 'url'


  sortListByZOrder: ->
    list = @$el.children('li').get()
    list.sort (a, b) ->
      compA = $(a).find('div').attr('data-zorder')
      compB = $(b).find('div').attr('data-zorder')
      if compB < compA then -1 else (if compB > compA then 1 else 0)

    $.each list, (index, widgetEl) -> @$el.append widgetEl


  makeSortable: ->
    options =
      opacity : 0.6
      axis    : 'y'
      update  : =>
        @updateListWidgets

    @$el.sortable(options)


  updateListWidgetsZ: ->
    for widget in App.builder.widgetLayer.widgets
      continue if widget.type is 'SpriteWidget'

      @$("[data-widget-id='#{widget.id}']").closest('li').index()
      spriteZOrder = App.builder.widgetLayer.widgets.length - spriteIndex

      App.vent.trigger 'widget:change_zorder'


  hasWidget: (widget) =>
    @$("div[data-widget-id=#{widget.id}]").length


  removeSpriteWidget: (e) =>
    id = $(e.currentTarget).siblings('.sprite-image').data 'widget-id'
    widget = App.builder.widgetLayer.getWidgetById(id)

    if App.builder.widgetLayer.removeWidget(widget) || App.currentScene().removeWidget(widget)
      @removeWidget(widget)


  removeWidget: (widget) =>
    @removeListEntry(widget)
    App.spriteForm.resetForm()


  removeListEntry: (widget) =>
    return unless widget.type is "SpriteWidget"

    @$("div[data-widget-id=#{widget.id}]").parent().remove()


  removeAll: =>
    @$el.empty()


  deselectAll: ->
    @$('.active').removeClass 'active'
