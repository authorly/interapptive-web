# Manages the list of keyframes (from the current scene).
# Also manages the current keyframe selection and populates the WidgetLayer
# accordingly.
class App.Views.KeyframeIndex extends Backbone.View

  tagName:   'ul'

  className: 'keyframe-list'

  initialize: ->
    @listenTo @collection, 'reset',            @render
    @listenTo @collection, 'add',              @appendKeyframe
    @listenTo @collection, 'remove',           @removeKeyframe
    @listenTo @collection, 'change:positions', @_updatePositions
    @listenTo @collection, 'synchronization-start synchronization-end', @_toggleEnabled

    # Put in its own view
    @listenTo App.vent, 'window:resize', @adjustSize

    @keyframeViews = []


  remove: ->
    @stopListening()
    @_removeKeyframeViews()
    super


  render: ->
    @$el.empty()

    if @collection.length > 0
      @collection.each (keyframe) =>
        @renderKeyframe(keyframe)
      @_updateDeleteButtons()

    @initSortable()

    @adjustSize()

    @switchKeyframe(@collection.findWhere(position: 0) || @collection.at(0))

    if @collection.scene.isMainMenu()
      @$el.hide()
    else
      @$el.show()

    @


  appendKeyframe: (keyframe) =>
    @renderKeyframe(keyframe)
    @_updateDeleteButtons()

    @switchKeyframe(keyframe)


  renderKeyframe: (keyframe) =>
    view = new App.Views.Keyframe(model: keyframe)
    viewElement = view.render().el
    index = @collection.indexOf(keyframe)
    if index == 0
      @$el.prepend viewElement
    else
      @$el.children().eq(index-1).after(viewElement)

    @keyframeViews.push(view)


  switchKeyframe: (newKeyframe) ->
    App.currentSelection.set
      keyframe: newKeyframe


  removeKeyframe: (keyframe, __, options) =>
    _.find(@keyframeViews, (k) -> k.model == keyframe).remove()
    @switchKeyframe(@collection.at(options.index) or @collection.at(options.index - 1))
    @_updateDeleteButtons()


  initSortable: =>
    @$el.sortable
      axis:        'x'
      cancel:      ''
      containment: 'footer'
      items:       'li[data-is_animation!="1"]'
      handle:      '.main'
      opacity:     0.6
      update:      @_numberKeyframes


  adjustSize: =>
    maxWidth = $(window).width() - $('.new-keyframe').outerWidth() - $('#scene-list').width() - $('#asset-library-sidebar').width() - 20
    @$el.css "max-width", "#{maxWidth}px"


  _numberKeyframes: =>
    @$('li[data-is_animation!="1"]').each (index, element) =>
      element = $(element)

      if (id = element.data('id'))? && (keyframe = @collection.get(id))?
        keyframe.set position: index

    # Backbone bug - without timeout the model is added twice
    window.setTimeout ( =>
      @collection.sort silent: true
      @collection.savePositions()
    ), 0


  _updatePositions: =>
    @$('li[data-is_animation!="1"]').each (__, element) =>
      element = $(element)

      if (id = element.data('id'))? && (keyframe = @collection.get(id))?
        element.find('.keyframe-number').text(keyframe.get('position') + 1)


  _updateDeleteButtons: ->
    show_delete = @collection.length > 1

    buttons = @$('li .delete-keyframe')
    if @collection.length > 1 then buttons.show() else buttons.hide()


  _removeKeyframeViews: ->
    _.each(@keyframeViews, (kv) -> kv.remove())
    @keyframeViews.length = 0


  _toggleEnabled: (__, synchronizing) ->
    if synchronizing
      @$el.addClass(   'disabled').sortable('option', 'disabled', true)
    else
      @$el.removeClass('disabled').sortable('option', 'disabled', false)
