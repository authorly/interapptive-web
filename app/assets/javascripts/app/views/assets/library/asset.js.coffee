class App.Views.AssetLibraryElement extends Backbone.View
  tagName:  'li'

  template: (data) ->
    JST[@options.templateName || 'app/templates/assets/library/asset'](data)


  events: ->
    'click .delete': 'deleteClicked'

  render: ->
    @$el.html @template(
      asset: @model
      type:  @type()
      title: @title()
      size:  @size()
      background: @model.get('thumbnail_url')
      duration: @model.get('duration')
    )

    @$el.addClass @type()
    @_createDraggable()

    @


  type: ->
    if @model instanceof App.Models.Image
      'image'
    else if @model instanceof App.Models.Video
      'video'
    else if @model instanceof App.Models.Sound
      'sound'


  remove: ->
    super
    @_removeDraggable()


  deleteClicked: ->
    event.stopPropagation()
    return unless confirm("Are you sure you want to delete this #{@type()} and corresponding #{@_assetTypeToWidgetType(@type())} from the storybook?")

    @model.destroy
      url: @model.get('delete_url')
      success: ->
        mixpanel.track "Deleted asset", type: @type()


  _assetTypeToWidgetType: (type) ->
    switch type
      when 'image' then 'scene images'
      when 'sound' then 'hotspots'
      when 'video' then 'hotspots'


  title: ->
    """
    #{@model.get('name')}
    #{@size()}
    Uploaded #{App.Lib.DateTimeHelper.timeToHuman(@model.get('created_at'))}
    """

  size: ->
    App.Lib.NumberHelper.numberToHumanSize(@model.get('size'))


  _createDraggable: ->
    if @$el.hasClass('js-draggable')
      element = @$el
      helper = (event) ->
        $('.thumb', $(event.currentTarget)).clone()

      # couldn't figure out how to get this dynamically
      # @dira 2013-08-19
      cursorAt =
        top:  30
        left: 25
    else
      element = @$('.js-draggable')
      helper = 'clone'
      cursorAt = false

    element.draggable
      helper: helper
      appendTo: 'body'
      cursor: 'move'
      cursorAt: cursorAt
      zIndex: 10000
      opacity: 0.5
      scroll: false
      start: (-> App.vent.trigger('assetDrag-start'))
      stop:  (-> App.vent.trigger('assetDrag-stop'))


  _removeDraggable: ->
    @$('.asset').draggable('destroy')

