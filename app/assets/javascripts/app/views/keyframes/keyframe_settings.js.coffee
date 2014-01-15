# Keyframe configuration.
# Manages the voiceovers configuration and the autoplay settings.
class App.Views.KeyframeSettings extends Backbone.View
  template: JST['app/templates/keyframes/settings']

  events:
    'click .nav li a': '_navigationClicked'


  render: ->
    App.trackUserAction 'Opened keyframe voiceover/configuration'

    @$el.html @template()
    @$('.nav li.active a').click()

    @voiceoverView = new App.Views.Voiceover model: @model
    @$('.tab.voiceover').html('').append(@voiceoverView.render().el)

    @autoplayDurationView = new App.Views.AutoplayDuration model: @model
    @$('.tab.autoplay').html('').append(@autoplayDurationView.render().el)

    @


  remove: ->
    @voiceoverView.remove()
    @autoplayDurationView.remove()
    super


  _navigationClicked: (event) ->
    element = @$(event.currentTarget).closest('li')
    element.addClass('active').siblings().removeClass('active')

    klass = _.find ['voiceover', 'autoplay'], (kls) -> element.hasClass(kls)

    @$(".modal-body .tab.#{klass}").show().siblings().hide()

    if klass is 'autoplay' then App.trackUserAction('Opened autoplay settings')
