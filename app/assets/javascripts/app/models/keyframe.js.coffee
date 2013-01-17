##
# Relations
# * @scene. It belongs to a scene. The scene is either provided in the attributes
# passed to the constructor, or is taken from the collection to which the scene
# belongs (if any)
class App.Models.Keyframe extends Backbone.Model
  paramRoot: 'keyframe'

  initialize: (options) ->
    @scene = options.scene if options?
    @on 'audiosync', @updateStorybookParagraph, @
    @initializePreview()


  updateStorybookParagraph: ->
    # RFCTR this is wrong. storybookJSON is a view reflecting the status of the
    # models. `Keyframe` should not know about it. Rather, storybookJSON should
    # listen to changes/events on keyframes (and all other models) and update
    # accordingly.
    # @author dira, @date 2013-01-14
    App.storybookJSON.updateParagraph(@)


  toJSON: ->
    # HACK a reference to the keyframe ends up in each widget
    # hash and creates a circular structure that cannot be
    # transformed to JSON (therefore, cannot be saved)
    json = super

    if json.widgets?
      _.each json.widgets, (w) ->
        delete w.keyframe
    json


  url: ->
    base = '/scenes/' + @getScene().id + '/'
    return  (base + 'keyframes.json') if @isNew()
    base + 'keyframes/' + @get('id') + '.json'


  getScene: =>
    @_scene ||= @scene || @collection.scene


  initializePreview: ->
    attributes = App.Lib.AttributesHelper.filterByPrefix @attributes, 'preview_image_'
    @preview = new App.Models.Preview(attributes)
    @preview.on 'change:data_url', => @trigger 'change:preview', @
    @preview.on 'change:id', =>
      @save preview_image_id: @preview.id


  hasWidget: (widget) ->
    _.any((@get('widgets') || []), (w) -> widget.id is w.id)


  addWidget: (widget) ->
    widgets = @get('widgets') || []
    widgets.push(widget.toHash())
    @set('widgets', widgets)
    @widgetsChanged()


  updateWidget: (widget) =>
    widgets = @get('widgets') || []

    for w, i in widgets
      if widget.id is w.id
        widgets[i] = widget.toHash()
        @widgetsChanged()
        return

    # Didn't update a widget, so we'll add it
    @addWidget(widget)


  removeWidget: (widget, skipWidgetLayerRemoval) ->
    widgets = @get('widgets')
    return false unless widgets?
    return false if widget instanceof App.Builder.Widgets.ButtonWidget

    for w, i in widgets
      if w.id == widget.id
        widgets.splice(i, 1)
        @widgetsChanged()
        break

    App.builder.widgetLayer.removeWidget(widget) unless skipWidgetLayerRemoval
    @widgetsChanged()
    true


  widgetsChanged: =>
    @trigger 'change:widgets', @
    @save()

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
    !@isAnimation() && @getScene().canAddText()


  isAnimation: ->
    @get('is_animation')

  spriteOrientationWidgetBySpriteWidget: (sprite_widget) ->
    @fetch(async: false)
    orientation = _.find(@widgets(), (widget) -> widget.sprite_widget_id == sprite_widget.id)
    return undefined unless orientation?
    orientation.sprite_widget = sprite_widget
    orientation

  nextTextSyncOrder: ->
    text_widgets = @widgetsByType('TextWidget')
    text_widget_with_max_sync_order = _.max(text_widgets, (w) -> w.sync_order)
    (text_widget_with_max_sync_order?.sync_order || 0) + 1


  widgets: ->
    widgets_array = @get('widgets')
    _.map(widgets_array, @_findOrCreateWidgetByWidgetHash, this)


  widgetsByType: (type) ->
    return [] unless type?
    _.filter(@widgets(), (w) -> w.type is type)


  _findOrCreateWidgetByWidgetHash: (widget_hash) ->
    widget = App.builder.widgetStore.find(widget_hash.id)
    return widget if widget?
    widget = new App.Builder.Widgets[widget_hash.type](_.extend(widget_hash, { keyframe: this }))
    App.builder.widgetStore.addWidget(widget)
    widget


  updateContentHighlightTimes: (times, options={}) ->
    @save { content_highlight_times: times },
      success: =>
        options.success() if options.success?
        ## RFCTR is this only on audiosync? what about other changes?
        # I moved this here since we don't need to use events to communicate
        # between an object and itself. The question still remains.
        # @author dira, @date 2013-01-14
        # @on 'audiosync', @updateStorybookParagraph, @
        @updateStorybookParagraph()


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
    # We add orientation widget to all the keyframes
    # even to the animation keyframes. That might not
    # be desired.
    keyframe = new App.Models.Keyframe(
      _.extend(attributes, {
        scene: @scene
        position: @nextPosition(attributes)
      }))

    sows = _.map(@scene.spriteWidgets(), (sprite_widget) ->
      new App.Builder.Widgets.SpriteOrientationWidget(
        keyframe: keyframe
        sprite_widget: sprite_widget
        sprite_widget_id: sprite_widget.id
      )
    )

    keyframe.save(widgets: _.map(sows, (sow) -> sow.toHash())
    , {
      wait: true
      success: =>
        # TODO RFCTR move this to keyframe, on parse/initialize or where
        # it's appropriate
        _.each(sows, (sow) -> sow.updateStorybookJSON())
    })
    @add(keyframe)


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
