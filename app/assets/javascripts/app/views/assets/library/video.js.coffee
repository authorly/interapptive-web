class App.Views.AssetLibraryVideo extends App.Views.AssetLibraryElement
  events:
    'click .control': 'play'


  render: ->
    super
    @$el.append $('<i class="control icon-play icon-black"/>')
    @


  remove: ->
    super

  play: (em) ->
    view = new App.Views.VideoPlayer(model: @model)
    App.vent.trigger('play:video', view)
