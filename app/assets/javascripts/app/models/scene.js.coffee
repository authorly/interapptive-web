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

    @listenTo @storybook.images, 'remove', @imageRemoved


  destroy: ->
    @stopListening()
    super


  sound: ->
    @storybook.sounds.get(@get('sound_id'))


  soundEffect: ->
    @storybook.sounds.get(@get('sound_effect_id'))


  initializeWidgets: ->
    @widgets.storybook ||= @storybook

    @listenTo @widgets, 'add', (widget) =>
      if widget instanceof App.Models.SpriteWidget
        widget.set z_order: @nextSpriteZOrder(widget)

    @listenTo @widgets, 'reset add remove change', @deferredSave


  initializeKeyframes: ->
    @_keyframesFetched = false
    @keyframes = new App.Collections.KeyframesCollection [], scene: @

    @listenTo @keyframes, 'add', @addOrientations


  fetchKeyframes: ->
      # 2013-09-20 @dira
      # TODO Use `reset: true` until the fix for backbone#2513 is released.
      # https://github.com/jashkenas/backbone/issues/2513
    @_keyframesFetchRequest ||= @keyframes.fetch(reset: true)


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
    # because positions actually depend on all the requests being complete
    # do not create unless the queue is empty
    # the UI should take care of it, but since it relies on CSS, it looks
    # like if you click fast enough, you can trigger a second creation request
    # before the button becomes disabled
    return unless @syncQueue().empty()

    @create {
      storybook: @storybook
      storybook_id: @storybook.id
      position: @nextPosition()
    }, {
      parse: true
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
