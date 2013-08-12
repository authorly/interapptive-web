class App.Views.AssetLibraryVideo extends App.Views.AssetLibraryElement
  events: ->
    _.extend {}, super, { 'click .control': 'play' }


  initialize: ->
    super
    @model.on 'change:transcode_complete', @render, @


  render: ->
    super
    if @model.get('transcode_complete')
      @$('.asset').after $('<i class="control icon-play icon-black"/>')
    else
      @$('.asset').after $('<i class="info icon-time icon-white" title="This video is being processed."/>')

    @


  remove: ->
    super
    @model.off 'change:transcode_complete', @render, @


  play: (em) ->
    view = new App.Views.VideoPlayer(model: @model)
    App.vent.trigger('play:video', view)


  title: ->
    title = super

    if (duration = @model.get('duration'))?
      title = title.replace("\n", "\n#{@model.get('duration').toFixed(2)} seconds\n")

    title = title.replace("\n", "\nProcessing\n") unless @model.get('transcode_complete')

    title
