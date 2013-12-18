class App.Views.Keyframe extends Backbone.View
  DELETE_KEYFRAME_MSG:
    '\nYou are about to delete a keyframe.\n\n\nAre you sure you want to continue?\n'

  template: JST["app/templates/keyframes/keyframe"]
  tagName: 'li'

  events:
    'click  .main':                       '_clicked'
    'click  .delete-keyframe':            '_deleteClicked'
    'change [name="animation-duration"]': '_changeAnimationDuration'
    'click  .keyframe-configuration':     '_configurationClicked'


  initialize: ->
    @listenTo App.currentSelection, 'change:keyframe', @_activeKeyframeChanged
    @listenTo @model, 'change:animation_duration',  @_animationDurationChanged
    @listenTo @model, 'invalid:animation_duration', @_invalidAnimationDurationEntered


  remove: ->
    @preview?.remove()
    super


  render: ->
    @$el.html(@template(keyframe: @model)).attr('data-id', @model.id)

    if @model.isAnimation()
      @$el.attr('data-is_animation', '1').addClass('animation')

    @preview = new App.Views.Preview
      model: @model.preview
      el: @$('.main')
      width: 150
      height: 112
    @preview.render()

    @


  _clicked: ->
    App.currentSelection.set keyframe: @model


  _configurationClicked: ->
    view = new App.Views.KeyframeSettings
      model: @model
    App.modalWithView(view: view).show()


  _activeKeyframeChanged: (__, keyframe) ->
    klass = 'active'
    if keyframe == @model
      @$el.addClass klass
    else
      @$el.removeClass klass


  _deleteClicked: (event) =>
    event.stopPropagation()
    return if @$el.hasClass('disabled')

    if confirm(@DELETE_KEYFRAME_MSG)
      if @model.isAnimation()
        App.trackUserAction 'Removed animation intro'
      else
        App.trackUserAction 'Deleted keyframe'

      collection = @model.collection
      @model.destroy
        success: =>
          collection.remove(@model)


  _changeAnimationDuration: (event) ->
    @model.set
      animation_duration: Number($(event.currentTarget).val())


  _animationDurationChanged: ->
    @$('[name=animation-duration]').val @model.get('animation_duration')


  _invalidAnimationDurationEntered: (duration) ->
    alert "Please enter a positive, one-decimal number for animation duration (e.g. 0, 3, 4.5). #{@$('[name=animation-duration]').val()} is not allowed"
