class App.Models.Scene extends Backbone.Model
  paramRoot: 'scene'

  url: ->
    base = '/storybooks/' + App.currentStorybook().get('id') + '/'
    return  (base + 'scenes.json') if @isNew()
    base + 'scenes/' + App.currentScene().get('id') + '.json'

  initialize: ->
    @on 'change:widgets', @save
    @on 'change:preview_image_id', @save

  setPreviewFrom: (keyframe) ->
    preview = keyframe.preview
    return if preview? && @preview? && preview.cid == @preview.cid

    if @preview?
      @preview.off 'change:id',       @previewIdChanged,  @
      @preview.off 'change:data_url', @previewUrlChanged, @

    @preview = preview

    @preview.on    'change:id',       @previewIdChanged,  @
    @preview.on    'change:data_url', @previewUrlChanged, @

    @previewIdChanged()
    @previewUrlChanged()


  previewIdChanged: ->
    @set
      preview_image_id:  @preview.id
      preview_image_url: @preview.src()


  previewUrlChanged: ->
    @trigger 'change:preview', @

  hasWidget: (widget) =>
    _.any((@get('widgets') || []), (w) -> widget.id is w.id)

  addWidget: (widget) =>
    widgets = @get('widgets') || []
    widgets.push(widget.toHash())
    @set('widgets', widgets)
    unless (widget instanceof App.Builder.Widgets.SpriteWidget) and not widget.isLoaded()
      @widgetsChanged()
    else
      widget.on 'loaded', => setTimeout @widgetsChanged, 0

  updateWidget: (widget, skipTrigger = false) =>
    widgets = @get('widgets') || []

    for w, i in widgets
      if widget.id is w.id
        widgets[i] = widget.toHash()
        @widgetsChanged() unless skipTrigger
        # Yes, we updated the widget.
        return true

    # If we make it this far, the widget doesn't exist, so let's add it
    @addWidget(widget)
    # No, we didn't update a widget. Addwidget calls its own widgetsChanged.
    false

  removeWidget: (widget, skipWidgetLayerRemoval) =>
    return unless (widgets = @get('widgets'))?

    for w, i in widgets
      if w.id == widget.id
        widgets.splice(i, 1)
        @widgetsChanged()
        break

    App.builder.widgetLayer.removeWidget(widget) unless skipWidgetLayerRemoval
    @widgetsChanged()

  widgetsChanged: =>
    @trigger 'change:widgets'


class App.Collections.ScenesCollection extends Backbone.Collection
  model: App.Models.Scene

  initialize: (models, options) ->
    if options
      this.storybook_id = options.storybook_id

  url: ->
    '/storybooks/' + this.storybook_id + '/scenes.json'

  ordinalUpdateUrl: (sceneId) ->
    '/storybooks/' + this.storybook_id + '/scenes/sort.json'

  comparator: (scene) ->
    scene.get 'position'

  reposition: (new_positions, el) ->
    $.ajax
      contentType:"application/json"
      dataType: 'json'
      type: 'POST'
      data: new_positions
      url: "#{@ordinalUpdateUrl(App.currentScene().get('id'))}"
      success: =>
        $(el).sortable('refresh')
        @fetch
         success: =>
           @trigger('reset', this)
