#= require_self
#= require ./models/base
#= require_tree ./models
#= require_tree ./views

window.Sim =
  Models: {}

  Views: {}

  config:
    particleSystemDefinition: '/assets/flower.plist'

  run: (json) ->
    cc.AudioEngine.getInstance().init('mp3,ogg')

    storybookModel = Sim.Models.Storybook.createFromJson(json)
    Sim.storybook = new Sim.Views.StorybookApplication(storybookModel)


  util:
    httpPath: (httpOrHttps) ->
      httpOrHttps.replace /^https:/, 'http:'

    normalizedFontName: (name) ->
      # replace URL for custom fonts - they are defined in `style` tags
      name = name.replace(/.*\//, '')
      name = name.replace(/\.ttf$/, '') # remove the extension
      name = 'Arial' if name == 'arialother' # undo hack for mobile
      name

