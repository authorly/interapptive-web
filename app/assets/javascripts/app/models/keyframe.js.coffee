class App.Models.Keyframe extends Backbone.Model
  paramRoot: 'keyframe'

  url: ->
    base = '/scenes/' + App.currentScene().get('id') + '/'
    return  (base + 'keyframes.json') if @isNew()
    base + 'keyframes/' + @get('id') + '.json'

  initialize: ->
    @on 'change:widgets', => @save()
    @initializePreview()


  initializePreview: ->
    attributes = App.Lib.AttributesHelper.filterByPrefix @attributes, 'preview_image_'
    @preview = new App.Models.Preview(attributes)
    @preview.on 'change:data_url', => @trigger 'change:preview', @
    @preview.on 'change:id', =>
      @set preview_image_id: @preview.id
      @save()

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
    return unless widgets?

    for w, i in widgets
      if w.id == widget.id
        widgets.splice(i, 1)
        @widgetsChanged()
        break

    App.builder.widgetLayer.removeWidget(widget)


  widgetsChanged: =>
    @trigger 'change:widgets', @


  save: ->
    if arguments.length > 0
      @_actualSave.apply @, arguments
    else
      # Use `debounce` to actually save only once if save is called
      # rapid sequence (as it happens when multiple change events are fired
      # asynchronously, from different sources, but close to one another in time)
      # To take advantage of this, use `set` to change the attributes, followed by
      # `save` # without parameters
      @_debouncedSave().apply @


  _debouncedSave: ->
    @_deboucedSaveMemoized ||= _.debounce @_actualSave, 500


  _actualSave: =>
    Backbone.Model.prototype.save.apply @, arguments


class App.Collections.KeyframesCollection extends Backbone.Collection
  model: App.Models.Keyframe

  paramRoot: 'keyframe'


  initialize: (models, options) ->
    # TODO move cache to a separate class
    @on 'reset', => @savePositionsCache(@positionsJSON())

    if options
      this.scene_id = options.scene_id


  url: ->
    '/scenes/' + this.scene_id + '/keyframes.json'


  ordinalUpdateUrl: ->
    '/scenes/' + @scene_id + '/keyframes/sort.json'


  toModdedJSON: ->
    return {"keyframes": this.toJSON()}


  comparator: (keyframe) ->
    keyframe.get 'position'


  savePositions: ->
    positions = @positionsJSON()
    return unless @positionsJSONIsDifferent(positions)

    @savePositionsCache(positions)
    $.ajax
      contentType:"application/json"
      dataType: 'json'
      type: 'POST'
      data: JSON.stringify positions
      url: @ordinalUpdateUrl()


  savePositionsCache: (positions) ->
    @positionsJSONCache = positions


  positionsJSONIsDifferent: (positions) ->
    JSON.stringify(@positionsJSONCache) != JSON.stringify(positions)


  positionsJSON: ->
    JSON = { keyframes: [] }

    @each (element) ->
      JSON.keyframes.push
        id: element.get 'id'
        position: element.get 'position'

    JSON
