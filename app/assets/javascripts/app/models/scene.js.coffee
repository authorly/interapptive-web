class App.Models.Scene extends Backbone.Model
  paramRoot: 'scene'

  url: ->
    "/storybooks/#{@get('storybook_id')}/" +
    if @isNew()
      'scenes.json'
    else
      "scenes/#{@id}.json"

  initialize: ->
    @on 'change:preview_image_id', @save


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


  previewIdChanged: ->
    @set
      preview_image_id:  @preview.id
      preview_image_url: @preview.src()


  previewUrlChanged: ->
    @trigger 'change:preview', @


  isMainMenu: ->
    @get('is_main_menu')


  canAddText: ->
    !@isMainMenu()


  canAddKeyframes: ->
    !@isMainMenu()


class App.Collections.ScenesCollection extends Backbone.Collection
  model: App.Models.Scene

  initialize: (models, options) ->

    if options
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
