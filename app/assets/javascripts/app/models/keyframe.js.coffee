class App.Models.Keyframe extends Backbone.Model
  paramRoot: 'keyframe'

  url: ->
    base = '/scenes/' + App.currentScene().get('id') + '/'
    return  (base + 'keyframes.json') if @isNew()
    base + 'keyframes/' + App.currentKeyframe().get('id') + '.json'

  addWidget: (widget) ->
    widgets = @get('widgets') || []
    widgets.push(widget.toHash())

    @set('widgets', widgets)

    @save()

  updateWidget: (widget) ->
    widgets = @get('widgets') || []

    for w, i in widgets
      if widget.id is w.id
        widgets[i] = widget.toHash()
        @set('widgets', widgets)
        @save()
        return

    # Didn't update a widget, so we'll add it
    @addWidget(widget)

  removeWidget: (widget) ->
    widgets = @get('widgets')
    return unless widgets?

    for w, i in widgets
      if w.id == widget.id
        widgets.splice(i, 1)
        @set('widgets', widgets)
        @save()
        break

class App.Collections.KeyframesCollection extends Backbone.Collection
  model: App.Models.Keyframe

  paramRoot: 'keyframe'

  initialize: (models, options) ->
    if options
      this.scene_id = options.scene_id

  url: ->
    '/scenes/' + this.scene_id + '/keyframes.json'

  ordinalUpdateUrl: (sceneId) ->
    '/scenes/' + sceneId + '/keyframes/sort.json'

  toModdedJSON: ->
    return {"keyframes": this.toJSON()}

  comparator: (keyframe) ->
    keyframe.get 'position'