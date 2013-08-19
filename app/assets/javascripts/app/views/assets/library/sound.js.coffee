class App.Views.AssetLibrarySound extends App.Views.AssetLibraryElement

  render: ->
    super

    @player = new App.Views.SoundPlayer(model: @model, className: 'player')
    @$('.thumb').append @player.render().el

    @


  remove: ->
    super

    @player?.remove()


  title: ->
    title = super

    if (duration = @model.get('duration'))?
      title = title.replace("\n", "\n#{@model.get('duration').toFixed(2)} seconds\n")

    title
