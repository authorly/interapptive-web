# Used for the menu for managing the sprites of the current keyframe.
class App.Views.ActiveSpritesList extends Backbone.View
  tagName:   'ul'
  className: 'sprites'
  events:
    'click .delete': 'removeSpriteWidget'
    'click li':      'setActiveSpriteWidget'


  render: ->
    @createAddImageEl()

    @declareAddSpriteListener()

    this


  declareAddSpriteListener: ->
    $('#active-sprites-window .icon-plus').on 'click', ->
      App.vent.trigger 'add:sprite'


  setActiveSpriteWidget: (e) ->
    widgetListItem = $(e.currentTarget)
    widgetId =       widgetListItem.find('div').attr('data-widget-id')
    activeWidget =   App.builder.widgetLayer.getWidgetById(widgetId)
    return unless activeWidget?

    activeWidget.setAsActive()
    App.builder.widgetLayer.setSelectedWidget(activeWidget)


  createAddImageEl: ->
    addImageEl = '<i class="icon-plus icon-black"></i>'
    $('#active-sprites-window').append(addImageEl)


  addSpriteToList: (widget) ->
    return unless widget.sprite

    view = new App.Views.SpriteWidget(widget: widget)
    $(@el).prepend(view.render().el)

    widget.on 'change', (what) ->
      view.render() if what == 'url'
    @sortListByZOrder()


  sortListByZOrder: ->
    $el =  $(@el)
    list = $el.children("li").get()

    list.sort (a, b) ->
      compA = $(a).find('div').attr('data-zorder')
      compB = $(b).find('div').attr('data-zorder')
      if compB < compA then -1 else (if compB > compA then 1 else 0)
    $.each list, (index, widgetEl) -> $el.append widgetEl


  makeSortable: ->
    options = {
        opacity: 0.6
        axis: 'y'
        update: =>
          @updateListWidgetsZ()
      }

    $(@el).sortable(options)


  updateListWidgetsZ: ->
    $el =      $(@el)
    widgetCt = App.builder.widgetLayer.widgets.length

    for widget in App.builder.widgetLayer.widgets
      continue if widget.type is "SpriteWidget"

      spriteIndex =  $el.find("[data-widget-id='#{widget.id}']").closest('li').index()
      spriteZOrder = widgetCt - spriteIndex

      widget.setZOrder(spriteZOrder)
      widget.trigger('change', 'zOrder')

      App.builder.widgetLayer.addWidget(widget, true)

  hasWidget: (widget) =>
    $(@el).find("div[data-widget-id=#{widget.id}]").length

  removeSpriteWidget: (e) =>
    widgetEl = $(e.currentTarget)
    widgetId = widgetEl.siblings('.sprite-image').data('widget-id')

    widget = App.builder.widgetLayer.getWidgetById(widgetId)
    if App.builder.widgetLayer.removeWidget(widget) || App.currentScene().removeWidget(widget)
      @removeWidget(widget)


  removeWidget: (widget) =>
    @removeListEntry(widget)
    App.spriteForm.resetForm()


  removeListEntry: (widget) =>
    $(@el).find("div[data-widget-id=#{widget.id}]").parent().remove()

  removeAll: ->
    $("#active-sprites-window ul").empty()

  deselectAll: ->
    $(@el).find('.active').removeClass('active')
