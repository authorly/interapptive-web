# Manages the list of keyframes (from the current scene).
# Also manages the current keyframe selection and populates the WidgetLayer
# accordingly.
class App.Views.KeyframeIndex extends Backbone.View

  tagName:   'ul'

  className: 'keyframe-list'

  events:
    'click  .main': 'keyframeClicked'
    'click  .delete-keyframe': 'destroyKeyframeClicked'

  DELETE_KEYFRAME_MSG:
    '\nYou are about to delete a keyframe.\n\n\nAre you sure you want to continue?\n'


  initialize: ->
    @collection.on 'reset',            @render,                 @
    @collection.on 'change:positions', @_updatePositions,       @
    @collection.on 'change:preview',   @keyframePreviewChanged, @
    @collection.on 'add',    @appendKeyframe
    @collection.on 'remove', @removeKeyframe
    @collection.on 'synchronization-start synchronization-end', @_toggleEnabled, @

    # Put in its own view
    App.vent.on 'window:resize', @adjustSize, @


    App.currentSelection.on 'change:keyframe', @keyframeChanged, @
    @keyframe_views = []


  # TODO RFCTR upgrate to Backbone 0.9.9 and use `listeTo` and `stopListening`
  # instead of `on` and `off`
  remove: ->
    super

    @collection.off 'change:positions reset', @render, @
    @collection.off 'change:preview', @keyframePreviewChanged, @
    @collection.off 'add'   , @appendKeyframe
    @collection.off 'remove', @removeKeyframe

    App.currentSelection.off 'change:keyframe', @keyframeChanged, @

    @_removeKeyframeViews()


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
    @renderKeyframe(keyframe, @collection.indexOf(keyframe))
    @_updateDeleteButtons()

    @switchKeyframe(keyframe)


  renderKeyframe: (keyframe, index) =>
    view = new App.Views.Keyframe(model: keyframe)
    viewElement = view.render().el
    if index == 0
      @$el.prepend viewElement

    else
      @$el.append  viewElement

    @keyframe_views.push(view)
    @keyframePreviewChanged(keyframe)


  keyframeClicked: (event) ->
    event.stopPropagation()

    keyframe = @collection.get $(event.currentTarget).attr('data-id')
    @switchKeyframe(keyframe)


  switchKeyframe: (newKeyframe) ->
    App.currentSelection.set keyframe: newKeyframe


  keyframeChanged: (__, keyframe) ->
    @$('li').removeClass('active').
      filter("[data-id=#{keyframe?.id}]").
      addClass('active')


  destroyKeyframeClicked: (event) =>
    event.stopPropagation()
    return if @$el.hasClass('disabled')

    if confirm(@DELETE_KEYFRAME_MSG)
      keyframe = @collection.get $(event.currentTarget).attr('data-id')
      keyframe.destroy
        success: =>
          @collection.remove(keyframe)


  removeKeyframe: (keyframe) =>
    index = @collection.indexOf(keyframe)
    $(".keyframe-list li[data-id=#{keyframe.id}]").remove()
    @switchKeyframe(@collection.at(index + 1) or @collection.at(index - 1))
    @_updateDeleteButtons()


  keyframePreviewChanged: (keyframe) ->
    src = keyframe.preview.src()
    if src?
      @$("div[data-id=#{keyframe.id}]").html("<img src='#{src}'/>")


  initSortable: =>
    @$el.sortable
      cancel      : ''
      containment : 'footer'
      items       : 'li[data-is_animation!="1"]'
      handle      : '.main'
      opacity     : 0.6
      update      : @_numberKeyframes


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
    buttons = @$('li .delete-keyframe')
    if @collection.canDeleteKeyframes() then buttons.show() else buttons.hide()


  _removeKeyframeViews: ->
    _.each(@keyframe_views, (kv) -> kv.remove())
    @keyframe_views.length = 0


  _toggleEnabled: (__, synchronizing) ->
    if synchronizing
      @$el.addClass(   'disabled').sortable('option', 'disabled', true)
    else
      @$el.removeClass('disabled').sortable('option', 'disabled', false)
