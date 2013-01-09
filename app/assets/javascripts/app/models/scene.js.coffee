class App.Models.Scene extends Backbone.Model
  paramRoot: 'scene'

  url: ->
    "/storybooks/#{@get('storybook_id')}/" +
    if @isNew()
      'scenes.json'
    else
      "scenes/#{@id}.json"


  initialize: ->
    @keyframes = new App.Collections.KeyframesCollection [], scene: @

    @on 'change:preview_image_id', @save
    @on 'keyframeadded', @addKeyframeToCollection


  fetchKeyframes: ->
    return if @isNew()

    @keyframes.fetch()


  toJSON: ->
    json = super
    # XXX PATCH - a reference to the scene ends up in each widget
    # hash and creates a circular structure that cannot be transformed to JSON
    # (therefore, cannot be saved)
    if json.widgets?
      _.each json.widgets, (widget) ->
        delete widget.scene
    json


  addKeyframeToCollection: (keyframe) ->
    @keyframes.push(keyframe)


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


  isMainMenu: ->
    @get('is_main_menu')


  canAddText: ->
    !@isMainMenu()


  canAddKeyframes: ->
    !@isMainMenu()


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
    if (widget.isSpriteWidget() ) && !widget.isLoaded()
      widget.on 'loaded', => setTimeout @widgetsChanged, 0
    else
      @widgetsChanged(widget)


  removeWidget: (widget, skipWidgetLayerRemoval) =>
    return unless (widgets = @get('widgets'))?

    for w, i in widgets
      if w.id == widget.id
        widgets.splice(i, 1)
        @widgetsChanged(widget)
        break

    App.builder.widgetLayer.removeWidget(widget) unless skipWidgetLayerRemoval
    @widgetsChanged()

  widgetsChanged: =>
    @save()

  spriteWidgets: ->
    _.select(@widgets(), (w) -> w.isSpriteWidget())

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

  initialize: (models, options={}) ->
    if options?
      this.storybook_id = options.storybook_id

    # TODO move cache to a separate class
    @on 'reset', =>
      @_savePositionsCache(@_positionsJSON())

    @on 'remove', (model, collection) ->
      collection._recalculatePositionsAfterDelete(model)


  url: ->
    '/storybooks/' + this.storybook_id + '/scenes.json'


  ordinalUpdateUrl: (sceneId) ->
    '/storybooks/' + this.storybook_id + '/scenes/sort.json'


  comparator: (scene) ->
    if scene.isMainMenu()
      -1
    else
      scene.get 'position'



  addScene: (scene) ->
    scene.save { position: @nextPosition(scene) },
      success: =>
        @add scene
        scene._getKeyframes(async: false)


  nextPosition: (scene) ->
    return null if scene.isMainMenu()
    @filter((scene) -> !scene.isMainMenu()).length


  savePositions: ->
    positions = @_positionsJSON()
    return unless @_positionsJSONIsDifferent(positions)

    @_savePositionsCache(positions)
    $.ajax
      contentType:"application/json"
      dataType: 'json'
      type: 'POST'
      data: JSON.stringify positions
      url: @ordinalUpdateUrl()
      success: =>
        @trigger 'change:positions'


  _savePositionsCache: (positions) ->
    @positionsJSONCache = positions


  _positionsJSONIsDifferent: (positions) ->
    JSON.stringify(@positionsJSONCache) != JSON.stringify(positions)


  _positionsJSON: ->
    JSON = { scenes: [] }

    @each (element) ->
      JSON.scenes.push
        id: element.get 'id'
        position: element.get 'position'

    JSON


  _recalculatePositionsAfterDelete: (model) ->
    return if model.isMainMenu()

    position = model.get('position')
    following = @filter (e) -> e.get('position') > position

    if following.length > 0
      _.each following, (e) ->
        e.set { position: e.get('position') - 1 }, silent: true

    @sort silent: true
    @savePositions()


  # reposition: (new_positions, el) ->
    # $.ajax
      # contentType:"application/json"
      # dataType: 'json'
      # type: 'POST'
      # data: new_positions
      # url: "#{@ordinalUpdateUrl(App.currentScene().get('id'))}"
      # success: =>
        # $(el).sortable('refresh')
        # @fetch
         # success: =>
           # @trigger('reset', this)
