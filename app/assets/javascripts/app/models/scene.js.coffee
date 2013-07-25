##
# Relations
# * it belongs to a story book. A Backbone model.
# * @keyframes. It has many keyframes. A Backbone collection.
# * @widgets. It has many widgets. A Backbone collection.
class App.Models.Scene extends Backbone.Model

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
    unless @widgets?
      @widgets = new App.Collections.Widgets(widgets)
      @widgets.scene = @

    attributes


  initialize: (attributes) ->
    @parse(attributes)
    @storybook ||= @collection?.storybook

    @initializeWidgets()
    @initializeKeyframes()

    @on 'change:preview_image_id change:widgets', @deferredSave

    @storybook.images.on 'remove', @imageRemoved, @


  sound: ->
    @storybook.sounds.get(@get('sound_id'))


  initializeWidgets: ->
    @widgets.storybook ||= @storybook

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
    return if @isNew() || @_keyframesFetchStarted
    @_keyframesFetchStarted = true

    @keyframes.fetch reset: true


  addNewKeyframe: (attributes) ->
    return unless @canAddKeyframes()

    @keyframes.addNewKeyframe(attributes)


  addOrientations: (keyframe) ->
    sourceKeyframe = if keyframe.isAnimation()
      # TODO change to findWhere from Backbone 1.4.4
      @keyframes.find (k) -> k.get('position') == 0
    else
      @keyframes.at(@keyframes.indexOf(keyframe) - 1)


    orientations = @spriteWidgets().map (spriteWidget) ->
      source = sourceKeyframe?.getOrientationFor(spriteWidget) || spriteWidget
      new App.Models.SpriteOrientation
        keyframe_id:      keyframe.id
        sprite_widget_id: spriteWidget.id
        position:         source.get('position')
        scale:            source.get('scale')

    keyframe.widgets.add orientations


  toJSON: ->
    _.extend super, widgets: @widgets.toJSON()


  isMainMenu: ->
    @get('is_main_menu')


  canAddText: ->
    !@isMainMenu()


  canAddKeyframes: ->
    !@isMainMenu()


  canAddAnimationKeyframe: ->
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


  spriteWidgets: ->
    @widgets.byClass(App.Models.SpriteWidget)


  buttonWidgets: ->
    @widgets.byClass(App.Models.ButtonWidget)


  nextSpriteZOrder: (widget) ->
    widgets = _.reject @spriteWidgets(), (sprite) -> sprite == widget
    if widgets.length > 0
      _.max(widgets.map( (widget) -> widget.get('z_order'))) + 1
    else
      return 1


  imageRemoved: (image) ->
    @widgets.imageRemoved(image)


  hasBackgroundSound: ->
    @has('sound_id')


_.extend App.Models.Scene::, App.Mixins.DeferredSave
_.extend App.Models.Scene::, App.Mixins.QueuedSync


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

    @on 'destroy', (model, collection) ->
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
    @create {
      storybook: @storybook
      storybook_id: @storybook.id
      position: @nextPosition()
    }, {
      wait: true
    }


  nextPosition: (scene=null) ->
    return null if scene?.isMainMenu()

    @filter((s) -> !s.isMainMenu()).length


  savePositions: ->
    positions = @_positionsJSON()
    return unless @_positionsJSONIsDifferent(positions)

    @_savePositionsCache(positions)

    @sync 'patch', Backbone,
      url: @ordinalUpdateUrl()
      data: JSON.stringify positions
      contentType:"application/json"
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

_.extend App.Collections.ScenesCollection::, App.Mixins.QueuedSync
