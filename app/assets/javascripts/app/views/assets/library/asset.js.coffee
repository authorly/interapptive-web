class App.Views.AssetLibraryElement extends Backbone.View
  tagName:  'li'

  template: (data) ->
    JST[@options.templateName || 'app/templates/assets/library/asset'](data)

  className: -> @type()

  events: ->
    'click .delete': 'deleteClicked'

  render: ->
    @$el.html @template(
      asset: @model
      type:  @type()
      title: @title()
      size:  @size()
      background: @model.get('thumbnail_url')
    )

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

