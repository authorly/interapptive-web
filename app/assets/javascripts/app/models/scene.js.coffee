class App.Models.Scene extends Backbone.Model
  paramRoot: 'scene'

  url: ->
    base = '/storybooks/' + App.currentStorybook().get('id') + '/'
    return  (base + 'scenes.json') if @isNew()
    base + 'scenes/' + App.currentScene().get('id') + '.json'

  initialize: ->
    @keyframes = new App.Collections.KeyframesCollection []
    @_getKeyframes(async: false)
    @on 'change:widgets', @save
    @on 'change:preview_image_id', @save

  _getKeyframes: (options) ->
    unless @isNew()
      @keyframes.url = "/scenes/#{@get('id')}/keyframes.json"
      @keyframes.fetch(options)
    @keyframes

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
    widgets.push(widget.toSceneHash())
    @set('widgets', widgets)
    console.log('called from here')
    if (widget instanceof App.Builder.Widgets.SpriteWidget) && !widget.isLoaded()
      widget.on 'loaded', => setTimeout @widgetsChanged, 0, widget
    else
      @widgetsChanged(widget)

  updateWidget: (widget, skipTrigger = false) =>
    widgets = @get('widgets') || []

    for w, i in widgets
      if widget.id is w.id
        widgets[i] = widget.toSceneHash()
        @widgetsChanged(widget) unless skipTrigger
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
        @widgetsChanged(widget)
        break

    App.builder.widgetLayer.removeWidget(widget) unless skipWidgetLayerRemoval
    @widgetsChanged()

  widgetsChanged: (widget) =>
    console.log('called from there')
    @trigger 'change:widgets', widget

  widgets: ->
    widgets_array = @get('widgets')
    _.map(widgets_array, @_findOrCreateWidgetByWidgetHash, this)

  _findOrCreateWidgetByWidgetHash: (widget_hash) ->
    widget = App.builder.widgetStore.find(widget_hash.id)
    return widget if widget
    widget = new App.Builder.Widgets[widget_hash.type](_.extend(widget_hash, { scene: this }))
    App.builder.widgetStore.addWidget(widget)
    widget


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
