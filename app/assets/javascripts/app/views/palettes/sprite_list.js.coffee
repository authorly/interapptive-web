#
# Used for the menu for managing the sprites of the current keyframe.
#
# Methods:
#   bringToFront - Brings a sprite (and element) to top of list
#
#   putInBack - Places sprite on botton of list (lowest z index)
#
class App.Views.SpriteListPalette extends Backbone.View
  tagName: 'ul'
  className: 'sprites'

  events:
    'click .delete':    'removeSprite'
    'click li':         'selectSprite'


  initialize: ->
    @collection.on 'add', @widgetAdded, @
    @collection.on 'remove', @widgetRemoved, @
    @collection.on 'change:image_id', @widgetChanged, @

    App.currentSelection.on 'change:widget', @spriteSelected, @

    App.vent.on 'bring_to_front:sprite', @bringToFront, @
    App.vent.on 'put_in_back:sprite', @putInBack, @

    @views = []


  widgetAdded: (widget) ->
    return if !@_isSprite(widget) or @_isHomeButton(widget)

    view = new App.Views.SpriteWidget(model: widget)
    rendered = view.render().el

    @views.push view
    @views.sort((v1, v2) -> v2.model.get('z_order') - v1.model.get('z_order'))

    index = @views.indexOf(view)
    if index == 0
      @$el.prepend(rendered)
    else
      @$el.children().eq(index-1).after(rendered)


  widgetRemoved: (widget) ->
    return unless @_isSprite(widget)

    view = @_getView(widget)
    view.$el.remove()
    @views.splice(@views.indexOf(view), 1)


  widgetChanged: (widget) ->
    return unless @_isSprite(widget)

    view = @_getView(widget)
    view.render()


  removeSprite: (e) ->
    id = $(e.currentTarget).siblings('.sprite-image').data 'widget-id'
    widget = @collection.get(id)
    widget.collection.scene.widgets.remove(widget)


  selectSprite: (e) ->
    e.stopPropagation()

    id = $('.sprite-image', e.currentTarget).data 'widget-id'
    widget = @collection.get(id)
    App.currentSelection.set widget: widget


  spriteSelected: (__, sprite) ->
    @$('li.active').removeClass('active')

    if (view = @_getView(sprite))?
      view.$el.addClass('active')


  bringToFront: (widget) =>
    el = @$("[data-widget-id='#{widget.get('id')}']").parent()
    @$el.prepend(el)
    @updateZOrder()


  putInBack: (widget) =>
    el = @$("[data-widget-id='#{widget.get('id')}']").parent()
    @$el.append(el)
    @updateZOrder()


  makeSortable: ->
    @$el.sortable
      opacity : 0.6
      axis    : 'y'
      update  : @updateZOrder


  hasWidget: (widget) =>
    @$("div[data-widget-id=#{widget.id}]").length


  _isSprite: (widget) ->
    widget instanceof App.Models.ImageWidget


  _isHomeButton: (widget) ->
    widget instanceof App.Models.ButtonWidget and widget.get('name') == 'home'


  _getView: (widget) ->
    view = _.find @views, (view) -> view.model == widget


  updateZOrder: =>
    nrSprites = @$('li').length
    for view in @views
      index = view.$el.closest('li').index()
      view.model.set z_order: nrSprites - index

    @collection.sort()
