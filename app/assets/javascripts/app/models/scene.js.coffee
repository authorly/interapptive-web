##
# Relations
# * it belongs to a story book. A Backbone model.
# * @keyframes. It has many keyframes. A Backbone collection.
# * @widgets. It has many widgets. A Backbone collection.
class App.Models.Scene extends Backbone.Model
  paramRoot: 'scene'


  url: ->
    "/storybooks/#{@storybook.id}/" +
    if @isNew()
      'scenes.json'
    else
      "scenes/#{@id}.json"


  parse: (attributes={}) ->
    @storybook ||= attributes?.storybook
    delete attributes.storybook

    widgets = attributes.widgets; delete attributes.widgets
    if @widgets?
      # RFCTR enable this when upgrading to Backbone 0.9.9
      # @widgets.update(widgets)
    else
      @widgets = new App.Collections.Widgets(widgets)
      @widgets.scene = @

    attributes


  initialize: (attributes) ->
    @parse(attributes)
    @storybook ||= @collection?.storybook

    @initializeWidgets()
    @initializeKeyframes()

    @on 'change:preview_image_id change:font_color change:font_size change:font_face change:widgets', @save


  initializeWidgets: ->
    @widgets.on 'add', (widget) =>
      if widget instanceof App.Models.SpriteWidget
        widget.set z_order: @nextSpriteZOrder(widget)

    @widgets.on 'reset add remove change', =>
      @trigger 'change:widgets change'


  initializeKeyframes: ->
    @_keyframesFetched = false
    @keyframes = new App.Collections.KeyframesCollection [], scene: @

    @keyframes.on 'add', @addOrientations, @
    @keyframes.on 'reset add remove change:positions', @updatePreview, @


  fetchKeyframes: ->
    return if @isNew() || @_keyframesFetched

    @keyframes.fetch
      success: => @_keyframesFetched = true


  addNewKeyframe: (attributes) ->
    return unless @canAddKeyframes()

    @keyframes.addNewKeyframe(attributes)


  addOrientations: (keyframe) ->
    previousKeyframe = @keyframes.at(@keyframes.indexOf(keyframe) - 1)

    orientations = @spriteWidgets().map (spriteWidget) ->
      source = previousKeyframe?.getOrientationFor(spriteWidget) || spriteWidget
      new App.Models.SpriteOrientation
        keyframe_id:      keyframe.id
        sprite_widget_id: spriteWidget.id
        position:         source.get('position')
        scale:            source.get('scale')

    keyframe.widgets.add orientations


  toJSON: ->
    return if @widgets instanceof Array
    _.extend super, widgets: @widgets.toJSON()


  isMainMenu: ->
    @get('is_main_menu')


  canAddText: ->
    !@isMainMenu()


  canAddKeyframes: ->
    !@isMainMenu()


  announceAnimation: ->
    App.vent.trigger 'can_add:animationKeyframe',
      @canAddKeyframes() && !@keyframes.animationPresent()


  # If a change affected which is the preview of the current scene, update
  updatePreview: ->
    preview = @keyframes.at(0).preview
    return if preview? && @preview? && preview.cid == @preview.cid

    @removePreviewListeners()
    @preview = preview
    @addPreviewListeners()

    @previewChanged()


  addPreviewListeners: ->
    @preview.on  'change:id change:url', @previewChanged,        @
    @preview.on  'change:data_url',      @previewDataUrlChanged, @


  removePreviewListeners: ->
    return unless @preview?

    @preview.off 'change:id change:url', @previewChanged,        @
    @preview.off 'change:data_url',      @previewDataUrlChanged, @


  previewChanged: ->
    @set
      preview_image_id:  @preview.id
      preview_image_url: @preview.get('url')


  previewDataUrlChanged: ->
    @trigger 'change:preview', @


  hotspotWidgets: ->
    @widgetsByClass(App.Models.HotspotWidget)

  spriteWidgets: ->
    @widgetsByClass(App.Models.SpriteWidget)


  buttonWidgets: ->
    @widgetsByClass(App.Models.ButtonWidget)


  widgetsByClass: (klass) ->
    @widgets.filter (w) -> w instanceof klass


  nextSpriteZOrder: (widget) ->
    widgets = _.reject @spriteWidgets(), (sprite) -> sprite == widget
    if widgets.length > 0
      _.max(widgets.map( (widget) -> widget.get('z_order'))) + 1
    else
      return 1


##
# Relations
# * @storybook - It belongs to a story book.
class App.Collections.ScenesCollection extends Backbone.Collection
  model: App.Models.Scene

  initialize: (models, options={}) ->
    @storybook = options.storybook

    # TODO move cache to a separate class
    @on 'reset', =>
      @_savePositionsCache(@_positionsJSON())

    @on 'remove', (model, collection) ->
      collection._recalculatePositionsAfterDelete(model)


  baseUrl: ->
    "/storybooks/#{@storybook.id}/scenes"

  url: ->
    @baseUrl() + '.json'


  ordinalUpdateUrl: ->
    @baseUrl() + '/sort.json'


  comparator: (scene) ->
    if scene.isMainMenu()
      -1
    else
      scene.get 'position'


  addNewScene: ->
    scene = new App.Models.Scene {
      storybook: @storybook
      storybook_id: @storybook.id
      position: @nextPosition()
    }, parse: true
    scene.save [],
      success: => @add scene


  nextPosition: (scene=null) ->
    return null if scene?.isMainMenu()

    @filter((s) -> !s.isMainMenu()).length


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
