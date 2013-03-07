#= require ../assets/sprites/sprite

# Used for the menu for managing the sprites of the current keyframe.
class App.Views.SpriteListPalette extends Backbone.View

  tagName: 'ul'

  className: 'sprites'

  template: JST['app/templates/palettes/sprite_list']

  events:
    'click .icon-plus': 'addSprite'
    'click .delete':    'removeSprite'
    'click li':         'selectSprite'


  initialize: ->
    @collection.on 'add', @widgetAdded, @
    @collection.on 'remove', @widgetRemoved, @
    @collection.on 'change:url', @widgetUrlChanged, @

    App.currentSelection.on 'change:widget', @spriteSelected, @

    @views = []


  render: ->
    @$el.html @template(title: @options.title)
    @initAddSpriteIconTooltip()
    @


  initAddSpriteIconTooltip: ->
    @$('.icon-plus').tooltip
      title:     'Add image...'
      placement: 'right'

  widgetAdded: (widget) ->
    return unless @_isSprite(widget)

    view = new App.Views.SpriteWidget(model: widget)
    @views.push view
    @$el.prepend(view.render().el)


  widgetRemoved: (widget) ->
    return unless @_isSprite(widget)

    view = @_getView(widget)
    view.$el.remove()
    @views.splice(@views.indexOf(view), 1)


  widgetUrlChanged: (widget) ->
    return unless @_isSprite(widget)

    view = @_getView(widget)
    view.render()


  addSprite: ->
    App.vent.trigger 'create:image'


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


  makeSortable: ->
    @$el.sortable
      opacity : 0.6
      axis    : 'y'
      update  : @updateZOrder


  hasWidget: (widget) =>
    @$("div[data-widget-id=#{widget.id}]").length


  _isSprite: (widget) ->
    widget instanceof App.Models.SpriteWidget


  _getView: (widget) ->
    view = _.find @views, (view) -> view.model == widget


  updateZOrder: =>
    nrSprites = @$('li').length
    for view in @views
      index = view.$el.closest('li').index()
      view.model.set z_order: nrSprites - index

    @collection.sort()
