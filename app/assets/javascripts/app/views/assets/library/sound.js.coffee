class App.Views.AssetLibrarySound extends App.Views.AssetLibraryElement

  render: ->
    super

    @player = new App.Views.SoundPlayer(model: @model, className: 'player')
    @$('.asset').after @player.render().el

    @


  remove: ->
    super

    @player?.remove()


  title: ->
    title = super

    return unless (duration = @model.get('duration'))?
    title.replace("\n", "\n#{@model.get('duration').toFixed(2)} seconds\n")
