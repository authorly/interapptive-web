class App.Models.Voiceover extends Backbone.Model

  initialize: (attributes) ->
    @_initializeKeyframe(attributes)
    @_initializeTimes()
    @set('valid', true) # Signifies validity of contained times


  texts: ->
    @keyframe.textWidgets()


  setValid: (state) ->
    @set('valid', state)


  _initializeKeyframe: (attributes) ->
    throw new Error('requires a keyframe') unless attributes.keyframe?
    @keyframe = attributes.keyframe


  _initializeTimes: ->
    # It is necessary to create a cloned array with different
    # object id. Otherwise changing 'times' and 'content_highlight_times'
    # will be same array object.
    times = _.clone(@keyframe.get('content_highlight_times'))
    @set('times', times)
