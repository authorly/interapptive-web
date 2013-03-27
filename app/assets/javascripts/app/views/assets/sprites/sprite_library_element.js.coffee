class App.Views.SpriteLibraryElement extends Backbone.View
  template: JST['app/templates/assets/sprites/sprite_library_element']
  tagName:  'li'
  events:
    'click .add': 'addImage'


  render: ->
    @$el.html(@template(sprite: @model))
    @$el.draggable
      opacity: 0.7
      helper: ->
        $(@).clone()
      appendTo: 'body'
      addClasses: false
      scroll: false
    @


  addImage: ->
    App.vent.trigger('create:image', @model)
