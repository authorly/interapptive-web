#
# Manage the sprites of the current scene.
#
class App.Views.SpriteList extends Backbone.View
  tagName: 'ol'
  className: 'sprites'

  events:
    'click .delete':    'removeSprite'
    'click .disable':   'disableSprite'
    'click .enable':    'enableSprite'
    'click li':         'selectSprite'


  initialize: ->
    @setCollection()
    @views = []

    @listenTo App.vent, 'bring_to_front:sprite put_in_back:sprite', @_widgetZOrderChanged
    @listenTo App.currentSelection, 'change:widget', @_activeWidgetChanged
    @_activeWidgetChanged()

    @makeSortable()


  setCollection: (collection) ->
    @_unsetCollection()
    @collection = collection
    @_setCollection()


  _setCollection: ->
    return unless @collection?

    @listenTo @collection, 'add',    @widgetAdded
    @listenTo @collection, 'remove', @widgetRemoved
    @listenTo @collection, 'change:image_id change:disabled', @widgetChanged

    @collection.each @widgetAdded


  _unsetCollection: ->
    return unless @collection?

    @stopListening @collection

    @collection.each @widgetRemoved


  widgetAdded: (widget) =>
    view = new App.Views.SpriteWidget(model: widget)
    rendered = view.render().el

    @views.push view
    @views.sort((v1, v2) -> v2.model.get('z_order') - v1.model.get('z_order'))

    index = @views.indexOf(view)
    if index == 0
      @$el.prepend(rendered)
    else
      @$el.children().eq(index-1).after(rendered)


  widgetRemoved: (widget) =>
    view = @_getView(widget)
    view.$el.remove()
    @views.splice(@views.indexOf(view), 1)


  widgetChanged: (widget) ->
    view = @_getView(widget)
    view.render()


  removeSprite: (e) ->
    e.stopPropagation()
    return unless confirm("Are you sure you want to remove this sprite from all the Scene Frames in current Scene?")

    widget = @_getWidget(e)
    widget.collection.remove(widget)


  disableSprite: (e) ->
    e.stopPropagation()

    widget = @_getWidget(e)
    return unless widget.canBeDisabled()
    widget.disable()


  enableSprite: (e) ->
    e.stopPropagation()

    widget = @_getWidget(e)
    return unless widget.canBeDisabled()
    widget.enable()


  _getWidget: (e) ->
    id = $(e.currentTarget).siblings('.sprite-image').data 'widget-id'
    @collection.get(id)


  selectSprite: (e) ->
    e.stopPropagation()

    id = $('.sprite-image', e.currentTarget).data 'widget-id'
    widget = @collection.get(id)
    App.currentSelection.set widget: widget


  spriteSelected: (sprite) ->
    @$('li.active').removeClass('active')

    if (view = @_getView(sprite))?
      view.$el.addClass('active')



  _getWidgetElement: (widget) ->
    @$("[data-widget-id='#{widget.id}']").parent()


  _updateZOrderOrRevert: (widget) ->
    ok = @updateZOrder()
    @_widgetZOrderChanged(widget) if !ok


  # remove & add to the correct position
  _widgetZOrderChanged: (widget) ->
    @widgetRemoved(widget)
    @widgetAdded(widget)


  _activeWidgetChanged: () ->
    widget = App.currentSelection.get('widget')
    @$('li.active').removeClass('active')
    @$("li[data-id='#{widget.id}']").addClass('active') if widget?


  makeSortable: ->
    @$el.sortable
      opacity : 0.6
      axis    : 'y'
      update  : =>
        @$el.sortable('cancel') unless @updateZOrder()


  _getView: (widget) ->
    view = _.find @views, (view) -> view.model == widget


  updateZOrder: =>
    order = []
    nrSprites = @$('li').length
    for view in @views
      index = view.$el.closest('li').index()
      order.push [nrSprites - index, view.model]

    if @collection.constructor.validZOrder(order)
      for [z_order, model] in order
        base = (new model.constructor).get('z_order') || 0
        model.set(z_order: base + z_order)
      true
    else
      alert('Please keep buttons above images')
      false
