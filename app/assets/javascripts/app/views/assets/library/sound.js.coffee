class App.Views.AssetLibrarySound extends App.Views.AssetLibraryElement
  initialize: ->
    super
    @model.on 'change:transcode_complete', @render, @


  render: ->
    super

    @player = new App.Views.SoundPlayer(model: @model, className: 'player')
    @$('.thumb').append @player.render().el

    @


  remove: ->
    super

    @model.off 'change:transcode_complete', @render, @
    @player?.remove()


  title: ->
    title = super

    if (duration = @model.get('duration'))?
      title = title.replace("\n", "\n#{@model.get('duration').toFixed(2)} seconds\n")

    title = title.replace("\n", "\nProcessing\n") unless @model.get('transcode_complete')

    title
