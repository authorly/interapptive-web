# Manages the list of keyframes of the current scene.
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
    @_removeKeyframeViews()
    @createAnimationView?.remove()
    super


  render: ->
    @$el.empty()

    if @collection.length > 0
      @collection.each (keyframe) =>
        @renderKeyframe(keyframe)

      @createAnimationView = new App.Views.CreateAnimationKeyframe
        collection: @collection
      @$el.prepend @createAnimationView.render().$el

      @_updateGlobalState()


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
    @_updateGlobalState()
    @switchKeyframe(keyframe)


  renderKeyframe: (keyframe) =>
    view = new App.Views.Keyframe(model: keyframe)
    viewElement = view.render().el
    position = keyframe.get 'position'
    if position == null
      @$el.prepend viewElement
    else
      @$el.append viewElement

    @keyframeViews.push(view)


  switchKeyframe: (newKeyframe) ->
    App.currentSelection.set
      keyframe: newKeyframe


  removeKeyframe: (keyframe, __, options) =>
    _.find(@keyframeViews, (k) -> k.model == keyframe).remove()
    @switchKeyframe(@collection.at(options.index) or @collection.at(options.index - 1))
    @_updateGlobalState()


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


  _updateGlobalState: ->
    @_updateDeleteButtons()
    el = @createAnimationView.$el
    if @collection.animationPresent()
      el.addClass('hidden')
    else
      el.removeClass('hidden')


  _updateDeleteButtons: ->
    buttons = @$('li[data-is_animation!="1"] .delete-keyframe')
    if @collection.canDeleteRegularKeyframes() then buttons.show() else buttons.hide()


  _removeKeyframeViews: ->
    _.each(@keyframeViews, (kv) -> kv.remove())
    @keyframeViews.length = 0


  _toggleEnabled: (__, synchronizing) ->
    if synchronizing
      @$el.addClass(   'disabled').sortable('option', 'disabled', true)
    else
      @$el.removeClass('disabled').sortable('option', 'disabled', false)
