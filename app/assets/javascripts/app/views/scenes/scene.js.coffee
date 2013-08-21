class App.Views.Scene extends Backbone.View
  template: JST['app/templates/scenes/scene']

  tagName: 'li'


  initialize: ->
    @model.on  'change:preview_data_url', @updatePreview, @
    @model.on  'destroy', @remove, @


  remove: ->
    @model.off 'change:preview_data_url', @updatePreview, @
    @model.off 'destroy', @remove, @
    super


  render: ->
    @$el.html(@template(scene: @model)).attr('data-id', @model.id)

    if @model.isMainMenu()
      @$el.attr('data-is_main_menu', '1').addClass('main_menu')

    @


  updatePreview:  =>
    @$('.scene-frame img')[0].src = @model.preview.src()
