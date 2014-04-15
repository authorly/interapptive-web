##
# Relations
# * @scene. It belongs to a scene. The scene is either provided in the attributes
# passed to the constructor, or is taken from the collection to which the scene
# belongs (if any). A Backbone model.
# * @widgets. It has many widgets. A Backbone Collection.
# Some of these widgets are SpriteOrientations. These belong to the keyframe
# (rather than the Scene, or the SpriteWidget) because this means that changing a
# position or a scale on this keyframe implies saving the keyframe to the server.
# Keeping the orientations in the Scene would imply saving the Scene everytime a
# position or scale is saved (in a specific Keyframe), which isn't natural.
#
# There is a special kind of keyframe: the animation keyframe, which has
# the attribute `is_animation` set to true.
# The purpose of the animation keyframe is to allow for a user to create
# an animation, which is played/triggered as soon as the end-user turns to a
# given scene. In the case of Stranger in the Woods, this animation is typically
# a zoom effect. The scene will start zoomed in on part of a picture (i.e.,
# an animal) and zoom out to it's regular size, resulting in a nice, smooth
# animation. Once the animation is done, text from the first keyframe would be
# shown.
class App.Models.Keyframe extends Backbone.Model

  defaults:
    animation_duration: 2.0

  parse: (attributes) ->
    widgets = attributes.widgets; delete attributes.widgets
    unless @widgets?
      @widgets = new App.Collections.Widgets(widgets)
      @widgets.keyframe = @

    attributes


  initialize: (attributes) ->
    @parse(attributes)

    @listenTo @, 'change:autoplay_duration', @autoplayDurationChanged
    @listenTo @, 'change:animation_duration', @animationDurationChanged
    @initializeScene(attributes)
    @initializeWidgets(attributes)
    @initializePreview()


  destroy: ->
    throw new Error('cannot delete') unless @canBeDestroyed()

    @stopListening()
    @uninitializeWidgets()
    @uninitializePreview()

    super


  initializeScene: (attributes) ->
    @scene = attributes?.scene || @collection?.scene
    delete @attributes.scene


  initializeWidgets: (attributes) ->
    @widgets.on 'add', (widget) =>
      if widget instanceof App.Models.TextWidget
        widget.set z_order: @nextTextZOrder(widget)
      else if widget instanceof App.Models.HotspotWidget
        widget.set z_order: @nextHotspotZOrder(widget)

    @widgets.on  'reset add remove change', @widgetsChanged, @

    @scene.widgets.on 'add',    @sceneWidgetAdded,   @
    @scene.widgets.on 'remove', @sceneWidgetRemoved, @

    @scene.storybook.sounds.on 'remove', @soundRemoved, @
    @scene.storybook.videos.on 'remove', @videoRemoved, @
    @scene.storybook.fonts.on  'remove', @fontRemoved, @

    @listenTo @widgets,        'add remove change:position change:scale change:radius',  @widgetsChangedPreview
    @listenTo @scene.widgets,  '           change:position change:scale change:z_order change:disabled change:image_id', @widgetsChangedPreview


  uninitializeWidgets: ->
    @widgets.off 'reset add remove change', @widgetsChanged, @

    @scene.widgets.off 'add',    @sceneWidgetAdded,   @
    @scene.widgets.off 'remove', @sceneWidgetRemoved, @


  widgetsChanged: ->
    @deferredSave()


  widgetsChangedPreview: (widget) ->
    @preview.widgetChanged(widget)


  # preferred this manual validation out of fear of not being able to save
  # keyframes at all, if this value gets set wrongly
  # @dira 2013-1018
  animationDurationChanged: ->
    duration = @get('animation_duration')
    if @constructor.isValidAnimationDuration(duration)
      @set animation_duration: duration
      @deferredSave()
    else
      @trigger 'invalid:animation_duration', duration
      @set
        animation_duration: @previousAttributes()['animation_duration']


  # preferred this manual validation out of fear of not being able to save
  # keyframes at all, if this value gets set wrongly
  # @dira 2013-10-29
  autoplayDurationChanged: ->
    duration = @get('autoplay_duration')
    if @constructor.isValidAutoplayDuration(duration)
      @set autoplay_duration: duration
      @deferredSave()
    else
      @trigger 'invalid:autoplay_duration', duration
      @set
        autoplay_duration: @previousAttributes()['autoplay_duration']


  toJSON: ->
    _.extend super, widgets: @widgets.toJSON()


  url: ->
    base = '/scenes/' + @scene.id + '/'
    return  (base + 'keyframes.json') if @isNew()
    base + 'keyframes/' + @get('id') + '.json'


  voiceover: ->
    @scene.storybook.sounds.get(@get('voiceover_id'))


  hasVoiceover: ->
    @voiceover()?


  # Autoplay duration in seconds
  autoplayDuration: ->
    duration = switch @autoplaySource()
      when 'field' then @get('autoplay_duration')
      when 'voiceover' then @voiceover().get('duration')
      when 'text'
        wordCount = _.map @textWidgets(), (widget) -> widget.wordCount()
        nrWords = _.reduce wordCount, ((sum, count) -> sum + count), 0
        speed = 45/60
        Math.round(nrWords / speed)
      when 'default' then 12

    # Add one second for leeway around transition time. See #1349
    # Add animation duration as well.
    duration + 1 + @get('animation_duration')


  autoplaySource: ->
    if @get('autoplay_duration')?
      'field'
    else
      if @voiceover()?.get('duration')?
        'voiceover'
      else if @textWidgets().length > 0
        'text'
      else
        'default'


  initializePreview: ->
    attributes = App.Lib.AttributesHelper.filterByPrefix @attributes, 'preview_image_'
    @preview = new App.Models.Preview(attributes, keyframe: @)
    @preview.on 'change:id', @_previewIdChanged, @


  uninitializePreview: ->
    @preview.off 'change:id', @_previewIdChanged, @


  soundRemoved: (sound) ->
    @widgets.soundRemoved(sound)


  videoRemoved: (video) ->
    @widgets.videoRemoved(video)


  fontRemoved: (font) ->
    @widgets.fontRemoved(font)


  _previewIdChanged: ->
    @save preview_image_id: @preview.id


  setPreviewDataUrl: (dataUrl) ->
    @preview.set 'data_url', dataUrl


  sceneWidgetAdded: (sceneWidget) ->
    if sceneWidget instanceof App.Models.SpriteWidget
      # add the widgets after adding `sceneWidget` finished (including its callbacks)
      window.setTimeout (=> @addOrientationFor(sceneWidget)), 0


  sceneWidgetRemoved: (sceneWidget) ->
    if sceneWidget instanceof App.Models.SpriteWidget
      @widgets.remove @getOrientationFor(sceneWidget)


  addOrientationFor: (spriteWidget) ->
    @widgets.add new App.Models.SpriteOrientation
      keyframe_id:      @id
      sprite_widget_id: spriteWidget.id
      position:         $.extend {}, spriteWidget.position
      scale:            spriteWidget.scale


  getOrientationFor: (widget) ->
    @widgets.find (w) ->
      w instanceof App.Models.SpriteOrientation &&
      w.get('sprite_widget_id') == widget.id


  canBeDestroyed: ->
    @isAnimation() || @collection.canDeleteRegularKeyframes()


  canAddText: ->
    !@isAnimation() && @scene.canAddText()


  canAddHotspot: ->
    !@scene.isMainMenu()


  hasText: ->
    @textWidgets().length > 0


  previous: ->
    @collection.at(@collection.indexOf(@) - 1)


  next: ->
    @collection.at(@collection.indexOf(@) + 1)


  isAnimation: ->
    @get('is_animation')


  announceVoiceover: ->
    App.vent.trigger 'can_add:voiceover', @hasText()


  textWidgets: ->
    @widgets.byClass(App.Models.TextWidget)


  hotspotWidgets: ->
    @widgets.byClass(App.Models.HotspotWidget)


  nextTextZOrder: (widget) ->
    widgets = _.reject @textWidgets(), (text) -> text == widget
    if widgets.length > 0
      _.max(widgets.map( (widget) -> widget.get('z_order'))) + 1
    else
      App.Models.TextWidget.prototype.defaults().z_order


  nextHotspotZOrder: (widget) ->
    widgets = _.reject @hotspotWidgets(), (hotspot) -> hotspot == widget
    if widgets.length > 0
      _.max(widgets.map( (widget) -> widget.get('z_order'))) + 1
    else
      App.Models.HotspotWidget.prototype.defaults().z_order


  @isValidAutoplayDuration: (duration) ->
    return false unless Number(duration) == duration and duration >= 0
    onlyOneDecimal = duration * 10 == Math.round (duration * 10)
    return false unless onlyOneDecimal
    true

  @isValidAnimationDuration: (duration) ->
    return false unless Number(duration) == duration and duration >= 0
    onlyOneDecimal = duration * 10 == Math.round (duration * 10)
    return false unless onlyOneDecimal
    true


_.extend App.Models.Keyframe::, App.Mixins.DeferredSave
_.extend App.Models.Keyframe::, App.Mixins.QueuedSync

##
# Relations:
# @scene - it belongs to a scene.

class App.Collections.KeyframesCollection extends Backbone.Collection
  model: App.Models.Keyframe

  initialize: (models, options) ->
    @scene = options.scene

    @on 'reset', =>
      # TODO move cache to a separate class
      @_savePositionsCache(@_positionsJSON())

    @on 'remove', (model, collection) ->
      collection._recalculatePositionsAfterDelete(model)


  url: ->
    '/scenes/' + @scene.id + '/keyframes.json'


  ordinalUpdateUrl: ->
    '/scenes/' + @scene.id + '/keyframes/sort.json'


  comparator: (keyframe) ->
    if keyframe.isAnimation()
      -1
    else
      keyframe.get 'position'


  animationPresent: ->
    @any (keyframe) -> keyframe.isAnimation()


  addNewKeyframe: (attributes={}) ->
    # because positions actually depend on all the requests being complete
    # do not create unless the queue is empty
    # the UI should take care of it, but since it relies on CSS, it looks
    # like if you click fast enough, you can trigger a second creation request
    # before the button becomes disabled
    return unless @syncQueue().empty()

    @create _.extend(attributes, {
      scene: @scene
      position: @nextPosition(attributes)
    }), {
      wait: true
    }


  canDeleteRegularKeyframes: ->
    iterator = (count, keyframe) ->
      count + if keyframe.isAnimation() then 0 else 1

    @reduce(iterator, 0) > 1


  nextPosition: (options) ->
    return null if options.is_animation
    @filter((k) -> !k.isAnimation()).length


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
    JSON = { keyframes: [] }

    @each (element) ->
      JSON.keyframes.push
        id: element.get 'id'
        position: element.get 'position'

    JSON

  _recalculatePositionsAfterDelete: (model) ->
    return if model.isAnimation()

    position = model.get('position')
    followingKeyframes = @filter (keyframe) -> keyframe.get('position') > position

    if followingKeyframes.length > 0
      _.each followingKeyframes, (keyframe) ->
        keyframe.set { position: keyframe.get('position') - 1 }, silent: true

    @sort silent: true
    @savePositions()

_.extend App.Collections.KeyframesCollection::, App.Mixins.QueuedSync
