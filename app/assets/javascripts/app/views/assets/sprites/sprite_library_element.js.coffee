class App.Views.SpriteLibraryElement extends Backbone.View
  template: JST['app/templates/assets/sprites/sprite_library_element']
  tagName:  'li'
  events:
    'click .add': 'addImage'


  render: ->
    @$el.html(@template(sprite: @model))
    @$('.sprite-image').draggable
      helper: 'clone'
      appendTo: 'body'
      zIndex: 10000
    @


  addImage: ->
    App.vent.trigger('create:image', @model)
