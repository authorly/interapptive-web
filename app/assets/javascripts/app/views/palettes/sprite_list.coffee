#= require ../assets/sprites/sprite

# Used for the menu for managing the sprites of the current keyframe.
class App.Views.SpriteListPalette extends Backbone.View

  tagName: 'ul'

  className: 'sprites'

  template: JST["app/templates/palettes/sprite_list"]

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

    @


  widgetAdded: (widget) ->
    return unless @_isSprite(widget)

    view = new App.Views.SpriteWidget(model: widget)
    @views.push view
    @$el.prepend(view.render().el)


  widgetRemoved: (widget) ->
    return unless @_isSprite(widget)

    view = @_getView(widget)
    view.el.remove()
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
      # update  : @updateListWidgetsZ


  hasWidget: (widget) =>
    @$("div[data-widget-id=#{widget.id}]").length


  _isSprite: (widget) ->
    widget instanceof App.Models.SpriteWidget


  _getView: (widget) ->
    view = _.find @views, (view) -> view.model == widget


  # setActiveSpriteWidget: (e) ->
    # widgetId =       $(e.currentTarget).find('div').attr('data-widget-id')
    # activeWidget =   App.builder.widgetLayer.getWidgetById(widgetId)
    # return unless activeWidget?

    # activeWidget.setAsActive()
    # App.builder.widgetLayer.setSelectedWidget(activeWidget)


  # sortListByZOrder: ->
    # list = @$el.children('li').get()
    # list.sort (a, b) ->
      # compA = $(a).find('div').attr('data-zorder')
      # compB = $(b).find('div').attr('data-zorder')
      # if compB < compA then -1 else (if compB > compA then 1 else 0)

    # $.each list, (index, widgetEl) -> @$el.append widgetEl




  # updateListWidgetsZ: ->
    # for widget in App.builder.widgetLayer.widgets
      # continue if widget.type is 'SpriteWidget'

      # @$("[data-widget-id='#{widget.id}']").closest('li').index()
      # spriteZOrder = App.builder.widgetLayer.widgets.length - spriteIndex

      # App.vent.trigger 'widget:change_zorder'




  # removeWidget: (widget) =>
    # @removeListEntry(widget)
    # App.spriteForm.resetForm()


  # removeListEntry: (widget) =>
    # return unless widget.type is "SpriteWidget"

    # @$("div[data-widget-id=#{widget.id}]").parent().remove()


  # removeAll: =>
    # @$el.empty()


  # deselectAll: ->
    # @$('.active').removeClass 'active'
