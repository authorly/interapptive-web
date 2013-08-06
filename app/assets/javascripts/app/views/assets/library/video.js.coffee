class App.Views.AssetLibraryVideo extends App.Views.AssetLibraryElement
  events: ->
    _.extend {}, super, { 'click .control': 'play' }


  render: ->
    super
    @$('.asset').after $('<i class="control icon-play icon-black"/>')
    @


  remove: ->
    super

  play: (em) ->
    view = new App.Views.VideoPlayer(model: @model)
    App.vent.trigger('play:video', view)
