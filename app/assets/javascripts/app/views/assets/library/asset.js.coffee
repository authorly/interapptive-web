class App.Views.AssetLibraryElement extends Backbone.View
  tagName:  'li'
  template: JST['app/templates/assets/library/asset']
  className: -> @type()

  render: ->
    @$el.html @template(
      asset: @model
      type: @type()
      title: @title()
      background: @model.get('thumbnail_url')
    )

    @_createDraggable()

    @


  type: ->
    @model.constructor.name.toLowerCase()

  remove: ->
    super
    @_removeDraggable()


  title: ->
    """
    #{@model.get('name')}
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

