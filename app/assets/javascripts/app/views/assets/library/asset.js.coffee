class App.Views.AssetLibraryElement extends Backbone.View
  tagName:  'li'
  template: JST['app/templates/assets/library/asset']
  events:
    'click .player .control': '_playerClicked'


  render: ->
    type = @model.constructor.name.toLowerCase()
    @$el.html @template(
      asset: @model
      type: type
      title: @title()
      background: @model.get('thumbnail_url')
    )

    @_createDraggable()

    @


  remove: ->
    super
    @_removeDraggable()
    if @model instanceof App.Models.Sound
      @_removePlayer()


  title: ->
    specificData = null
    if @model instanceof App.Models.Sound
      specificData = "#{@model.get('duration').toFixed(2)} seconds"

    """
    #{@model.get('name')}#{if specificData? then "\n#{specificData}" else ""}
    #{App.Lib.NumberHelper.numberToHumanSize(@model.get('size'))}
    Uploaded #{App.Lib.DateTimeHelper.timeToHuman(@model.get('created_at'))}
    """


  _createDraggable: ->
    @$('.asset').draggable
      helper: 'clone'
      appendTo: 'body'
      cursor: 'move'
      zIndex: 10000
      opacity: 0.5
      scroll: false
      start: (-> App.vent.trigger('assetDrag-start'))
      stop:  (-> App.vent.trigger('assetDrag-stop'))


  _removeDraggable: ->
    @$('.asset').draggable('destroy')


  _createPlayer: ->
    unless @player?
      @player = Popcorn("##{@model.cid}")
      @playerControl = @$('.player .control')
      @player.on 'ended', @_playerShowPlay, @


  _removePlayer: ->
    @player?.destroy()


  _soundPreviewEnded: ->


  _playerClicked: (event) ->
    event.stopPropagation()

    @_createPlayer()

    if @playerControl.hasClass('icon-play')
      @_playerShowStop()
      @player.play()
    else
      @_playerShowPlay()
      @player.pause()


  _playerShowPlay: =>
    @playerControl
      .addClass('icon-play')
      .removeClass('icon-stop')


  _playerShowStop: ->
    @playerControl
      .removeClass('icon-play')
      .addClass('icon-stop')
