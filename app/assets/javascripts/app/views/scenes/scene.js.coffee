class App.Views.Scene extends Backbone.View
  template: JST['app/templates/scenes/scene']

  tagName: 'li'


  initialize: ->
    @listenTo @model, 'destroy', @remove
    @listenTo @model.keyframes, 'reset add remove change:positions', @_updatePreview


  render: ->
    @$el.html(@template(scene: @model)).attr('data-id', @model.id)

    if @model.isMainMenu()
      @$el.attr('data-is_main_menu', '1').addClass('main_menu')

    @createPreview()

    @


  remove: ->
    @preview?.remove()
    super


  _updatePreview: ->
    renderedPreviewModel = @preview?.model
    previewModel = @currentPreview()
    return if previewModel? && renderedPreviewModel? &&
      previewModel.cid == renderedPreviewModel.cid

    @preview?.remove()
    @createPreview()


  createPreview: ->
    return unless @model.keyframes.length > 0

    @preview = new App.Views.Preview
      model: @currentPreview()
      el: @$('.scene-frame')
      width: 150
      height: 112
      skipSave: true
    @preview.render()


  currentPreview: ->
    @model.keyframes.at(0)?.preview
