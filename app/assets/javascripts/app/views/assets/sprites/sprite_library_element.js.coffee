class App.Views.SpriteLibraryElement extends Backbone.View
  template: JST['app/templates/assets/sprites/sprite_library_element']
  tagName:  'li'
  events:
    'click .add': 'addImage'


  render: ->
    @$el.html(@template(sprite: @model))
    @$el.tooltip
      title: @model.get('name')
      placement: 'left'
    @


  addImage: ->
    App.vent.trigger('create:image', @model)
