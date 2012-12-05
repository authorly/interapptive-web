class App.Models.Keyframe extends Backbone.Model
  paramRoot: 'keyframe'

  url: ->
    base = '/scenes/' + @scene.id + '/'
    return  (base + 'keyframes.json') if @isNew()
    base + 'keyframes/' + @get('id') + '.json'


  initialize: ->
    # must go through the scenesCollection, because the relationship
    # between the scene model and its keyframes is not stored anywhere
    @scene = App.scenesCollection.get @get('scene_id')
    @initializePreview()


  initializePreview: ->
    attributes = App.Lib.AttributesHelper.filterByPrefix @attributes, 'preview_image_'
    @preview = new App.Models.Preview(attributes)
    @preview.on 'change:data_url', => @trigger 'change:preview', @
    @preview.on 'change:id', =>
      @save preview_image_id: @preview.id


  addWidget: (widget) ->
    widgets = @get('widgets') || []
    widgets.push(widget.toHash())
    @set('widgets', widgets)
    if !(widget instanceof App.Builder.Widgets.SpriteWidget) or widget.isLoaded()
      @widgetsChanged()
    else
      widget.on 'loaded', => setTimeout @widgetsChanged, 0


  updateWidget: (widget) ->
    widgets = @get('widgets') || []

    for w, i in widgets
      if widget.id is w.id
        widgets[i] = widget.toHash()
        @widgetsChanged()
        return

    # Didn't update a widget, so we'll add it
    @addWidget(widget)


  removeWidget: (widget) ->
    widgets = @get('widgets')
    return false unless widgets?
    return false if widget instanceof App.Builder.Widgets.ButtonWidget

    for w, i in widgets
      if w.id == widget.id
        widgets.splice(i, 1)
        @widgetsChanged()
        break

    App.builder.widgetLayer.removeWidget(widget)
    true


  widgetsChanged: =>
    @trigger 'change:widgets', @
    @save()


  # save: =>
    # console.log 'save', @get('preview_image_id')
    # if arguments.length > 0
      # @_actualSave.apply @, arguments
    # else
      # # Use `debounce` to actually save only once if save is called
      # # rapid sequence (as it happens when multiple change events are fired
      # # asynchronously, from different sources, but close to one another in time)
      # # To take advantage of this, use `set` to change the attributes, followed by
      # # `save` # without parameters
      # @_debouncedSave().apply @


  canAddText: ->
    !@isAnimation() && @scene.canAddText()


  # _debouncedSave: ->
    # @_deboucedSaveMemoized ||= _.debounce @_actualSave, 500


  # _actualSave: =>
    # Backbone.Model.prototype.save.apply @, arguments


  isAnimation: ->
    @get('is_animation')


class App.Collections.KeyframesCollection extends Backbone.Collection
  model: App.Models.Keyframe

  paramRoot: 'keyframe'


  initialize: (models, options) ->
    # TODO move cache to a separate class
    @on 'reset', =>
      @announceAnimation()
      @_savePositionsCache(@_positionsJSON())

    @on 'add', (model, _collection, options) =>
      @announceAnimation()

    if options?
      @scene_id = options.scene_id

    @on 'remove', (model, collection) ->
      collection._recalculatePositionsAfterDelete(model)


  url: ->
    '/scenes/' + @scene_id + '/keyframes.json'


  ordinalUpdateUrl: ->
    '/scenes/' + @scene_id + '/keyframes/sort.json'


  toModdedJSON: ->
    return {"keyframes": this.toJSON()}


  comparator: (keyframe) ->
    if keyframe.isAnimation()
      -1
    else
      keyframe.get 'position'


  animationPresent: ->
    @any (keyframe) -> keyframe.isAnimation()


  announceAnimation: =>
    scene = App.scenesCollection.get(@scene_id)
    App.vent.trigger 'scene:can_add_animation',
      !@animationPresent() && scene.canAddKeyframes()


  nextPosition: (keyframe) ->
    return null if keyframe.isAnimation()
    @filter((keyframe) -> !keyframe.isAnimation()).length


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


  addKeyframe: (keyframe) ->
    keyframe.save { position: @nextPosition(keyframe) },
      success: =>
        # XXX necessary because this would blow if, in between `save` and
        # `success`, another scene was selected in the VIEW (!!), and therefore
        # @scene_id was changed
        # This is a temporary fix; having the collection change contents is a bad
        # idea.
        if keyframe.get('scene_id') == @scene_id
          @add keyframe


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
