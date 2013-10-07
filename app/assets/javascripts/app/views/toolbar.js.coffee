class App.Views.ToolbarView extends Backbone.View
  events:
    'click .scene'              : 'addScene'
    'click .edit-text'          : 'addText'
    'click .scene-options'      : 'showSettings'
    'click .background-sound'   : 'showSceneBackgroundMusic'
    'click .compile'            : 'compileStorybook'
    'click .logo'               : 'switchStorybook'


  compileStorybook: (event) ->
    platform = $(event.currentTarget).find('a').data('platform')
    App.currentSelection.get('storybook').compile(platform)

  initialize: ->
    @_enableOnEvent 'can_add:text', '.edit-text'
    @_enableOnEvent 'can_add:scene', '.scene'

    App.vent.on 'has_background_sound:scene', @_changeBackgroundSoundIcon

    App.vent.on 'activate:scene', (scene) =>
      @$('li').removeClass 'disabled'
      if scene.isMainMenu()
        @$('.edit-text').addClass 'disabled'


  addScene: (event) ->
    event.preventDefault()
    return if $(event.target).hasClass('disabled')

    App.vent.trigger 'create:scene'


  addText: (event) ->
    App.trackUserAction "Add text to a scene"

    event.preventDefault()
    return if $(event.target).hasClass('disabled')

    App.vent.trigger 'create:widget', type: 'TextWidget'



  showSettings: ->
    App.vent.trigger('show:settingsform')


  showSceneBackgroundMusic: ->
    App.vent.trigger('show:scenebackgroundsoundform')


  switchStorybook: ->
    App.trackUserAction 'Switch storybook'
    document.location.href = '/'


  _enableOnEvent: (event, selector) ->
    App.vent.on event, (enable) =>
      element = @$(selector)
      if enable
        element.removeClass 'disabled'
      else
        element.addClass 'disabled'


  _changeBackgroundSoundIcon: (hasBackgroundSound) =>
    el = @$('.background-sound')
    klass = 'has-sound'
    if hasBackgroundSound
      el.addClass klass
    else
      el.removeClass klass
