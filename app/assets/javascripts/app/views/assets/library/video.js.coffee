class App.Views.AssetLibraryVideo extends App.Views.AssetLibraryElement
  events: ->
    _.extend {}, super, { 'click': 'play' }


  initialize: ->
    super
    @model.on 'change:transcode_complete', @render, @


  render: ->
    super

    html = if @model.get('transcode_complete')
      '<div class="player"><i class="control icon-play icon-black"/></div>'
    else
      '<div class="info"><i class="icon-time icon-white" title="This video is being processed."/></div>'

    @$('.thumb').append $(html)

    @


  remove: ->
    super
    @model.off 'change:transcode_complete', @render, @


  play: (em) ->
    return unless $(em.target).closest('.player').length > 0
    return unless @model.get('transcode_complete')

    view = new App.Views.VideoPlayer(model: @model)
    App.vent.trigger('play:video', view)


  title: ->
    title = super

    if (duration = @model.get('duration'))?
      title = title.replace("\n", "\n#{@model.get('duration').toFixed(2)} seconds\n")

    title = title.replace("\n", "\nProcessing\n") unless @model.get('transcode_complete')

    title
