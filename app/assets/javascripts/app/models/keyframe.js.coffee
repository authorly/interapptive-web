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
  paramRoot: 'keyframe'

  initialize: (attributes) ->
    @initializeScenes(attributes)
    @initializeWidgets(attributes)
    @initializePreview()

    @widgets.on 'add remove change', => @save()
    @scene.widgets.on 'add',    @sceneWidgetAdded,   @
    @scene.widgets.on 'remove', @sceneWidgetRemoved, @


  initializeWidgets: (attributes) ->
    if @isNew()
      orientations = @scene.spriteWidgets().map @_orientationFor
      @widgets = new App.Collections.Widgets(orientations)
    else
      widgets = @get('widgets'); delete @attributes.widgets
      @widgets = new App.Collections.Widgets(widgets)


  initializeScenes: (attributes) ->
    @scene = attributes?.scene || @collection?.scene
    delete @attributes.scene


  toJSON: ->
    _.extend super, widgets: @widgets.toJSON()


  url: ->
    base = '/scenes/' + @scene.id + '/'
    return  (base + 'keyframes.json') if @isNew()
    base + 'keyframes/' + @get('id') + '.json'


  initializePreview: ->
    attributes = App.Lib.AttributesHelper.filterByPrefix @attributes, 'preview_image_'
    @preview = new App.Models.Preview(attributes)
    @preview.on 'change:data_url', => @trigger 'change:preview', @
    @preview.on 'change:id', =>
      @save preview_image_id: @preview.id


  sceneWidgetAdded: (sceneWidget) ->
    if sceneWidget.get('type') is 'SpriteWidget'
      @widgets.add @_orientationFor(sceneWidget)


  sceneWidgetRemoved: (sceneWidget) ->
    if sceneWidget.get('type') is 'SpriteWidget'
      @widgets.remove @getOrientationFor(widgets)


  _orientationFor: (spriteWidget) ->
    new App.Models.SpriteOrientation
      keyframe_id:      @id
      sprite_widget_id: spriteWidget.id
      # TODO get the position from the previous keyframe, it's more logical
      # to keep it than to use the initial position
      position:         spriteWidget.get('position')
      scale:            spriteWidget.get('scale')


  getOrientationFor: (widget) ->
    @widgets.find (w) ->
      w.get('type') == 'SpriteOrientation' &&
      w.get('sprite_widget_id') == widget.id


  # RFCTR widgets
  # hasWidget: (widget) ->
    # _.any((@get('widgets') || []), (w) -> widget.id is w.id)


  # addWidget: (widget) ->
    # widgets = @get('widgets') || []
    # widgets.push(widget.toHash())
    # @set('widgets', widgets)
    # @widgetsChanged()


  # updateWidget: (widget) =>
    # widgets = @get('widgets') || []

    # for w, i in widgets
      # if widget.id is w.id
        # widgets[i] = widget.toHash()
        # @widgetsChanged()
        # return

    # # Didn't update a widget, so we'll add it
    # @addWidget(widget)


  # removeWidget: (widget, skipWidgetLayerRemoval) ->
    # widgets = @get('widgets')
    # return false unless widgets?
    # return false if widget instanceof App.Builder.Widgets.ButtonWidget

    # for w, i in widgets
      # if w.id == widget.id
        # widgets.splice(i, 1)
        # @widgetsChanged()
        # break

    # App.builder.widgetLayer.removeWidget(widget) unless skipWidgetLayerRemoval
    # @widgetsChanged()
    # true


  # widgetsChanged: =>
    # @trigger 'change:widgets', @
    # @save()

  # spriteOrientationWidgetBySpriteWidget: (sprite_widget) ->
    # @fetch(async: false)
    # orientation = _.find(@widgets(), (widget) -> widget.sprite_widget_id == sprite_widget.id)
    # return undefined unless orientation?
    # orientation.sprite_widget = sprite_widget
    # orientation

  # widgets: ->
    # widgets_array = @get('widgets')
    # _.map(widgets_array, @_findOrCreateWidgetByWidgetHash, this)

  # _findOrCreateWidgetByWidgetHash: (widget_hash) ->
    # widget = App.builder.widgetStore.find(widget_hash.id)
    # return widget if widget?
    # widget = new App.Builder.Widgets[widget_hash.type](_.extend(widget_hash, { keyframe: this }))
    # App.builder.widgetStore.addWidget(widget)
    # widget




  # save: ->
    # if arguments.length > 0
      # @_actualSave.apply @, arguments
    # else
      # # Use `debounce` to actually save only once if save is called
      # # rapid sequence (as it happens when multiple change events are fired
      # # asynchronously, from different sources, but close to one another in time)
      # # To take advantage of this, use `set` to change the attributes, followed by
      # # `save` # without parameters
      # @_debouncedSave().apply @


  # _debouncedSave: ->
    # @_deboucedSaveMemoized ||= _.debounce @_actualSave, 500


  # _actualSave: =>
    # Backbone.Model.prototype.save.apply @, arguments


  canAddText: ->
    !@isAnimation() && @scene.canAddText()


  isAnimation: ->
    @get('is_animation')


  # spriteOrientationWidgetBySpriteWidget: (sprite_widget) ->
    # @fetch(async: false)
    # orientation = _.find(@widgets(), (widget) -> widget.sprite_widget_id == sprite_widget.id)
    # return undefined unless orientation?
    # orientation.sprite_widget = sprite_widget
    # orientation


  nextTextSyncOrder: ->
    text_widgets = @widgetsByType('TextWidget')
    text_widget_with_max_sync_order = _.max(text_widgets, (w) -> w.sync_order)
    (text_widget_with_max_sync_order?.sync_order || 0) + 1


  # widgets: ->
    # widgets_array = @get('widgets')
    # _.map(widgets_array, @_findOrCreateWidgetByWidgetHash, this)


  widgetsByType: (type) ->
    return [] unless type?
    _.filter(@widgets, (w) -> w.type is type)


  # _findOrCreateWidgetByWidgetHash: (widget_hash) ->
    # widget = App.builder.widgetStore.find(widget_hash.id)
    # return widget if widget?
    # widget = new App.Builder.Widgets[widget_hash.type](_.extend(widget_hash, { keyframe: this }))
    # App.builder.widgetStore.addWidget(widget)
    # widget


  updateContentHighlightTimes: (times, options={}) ->
    @save { content_highlight_times: times }, options


##
# Relations:
# @scene - it belongs to a scene.

class App.Collections.KeyframesCollection extends Backbone.Collection
  model: App.Models.Keyframe

  paramRoot: 'keyframe'


  initialize: (models, options) ->
    @scene = options.scene

    @on 'reset', =>
      @announceAnimation()
      # TODO move cache to a separate class
      @_savePositionsCache(@_positionsJSON())

    @on 'add remove', (model, _collection, options) =>
      @announceAnimation()

    @on 'remove', (model, collection) ->
      collection._recalculatePositionsAfterDelete(model)


  url: ->
    '/scenes/' + @scene.id + '/keyframes.json'


  ordinalUpdateUrl: ->
    '/scenes/' + @scene.id + '/keyframes/sort.json'


  toModdedJSON: ->
    return {"keyframes": this.toJSON()}


  comparator: (keyframe) ->
    if keyframe.isAnimation()
      -1
    else
      keyframe.get 'position'


  animationPresent: ->
    @any (keyframe) -> keyframe.isAnimation()


  announceAnimation: ->
    App.vent.trigger 'scene:can_add_animation',
      !@animationPresent() && @scene.canAddKeyframes()


  addNewKeyframe: (attributes={}) ->
    @create new App.Models.Keyframe(
      _.extend(attributes, {
        scene: @scene
        position: @nextPosition(attributes)
      })
    )


    keyframe.save()


  nextPosition: (options) ->
    return null if options.is_animation
    @filter((k) -> !k.isAnimation()).length


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
