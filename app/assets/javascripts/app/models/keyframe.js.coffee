class App.Models.Keyframe extends Backbone.Model
  paramRoot: 'keyframe'

  url: ->
    base = '/scenes/' + App.currentScene().get('id') + '/'
    return  (base + 'keyframes.json') if @isNew()
    base + 'keyframes/' + App.currentKeyframe().get('id') + '.json'

  initialize: ->
    # FIXME hack to populate paragraphs
    page = @getScene().page

    @paragraph =
      delayForPanning: true
      highlightingTimes: []
      linesOfText: []
      voiceAudioFile: ""

    page.Page.text.paragraphs.push(@paragraph)

  # FIXME hacky method to get the scene
  getScene: ->
    return App.currentScene()

class App.Collections.KeyframesCollection extends Backbone.Collection
  model: App.Models.Keyframe

  initialize: (models, options) ->
    if options
      this.scene_id = options.scene_id

  url: ->
    '/scenes/' + this.scene_id + '/keyframes.json'
