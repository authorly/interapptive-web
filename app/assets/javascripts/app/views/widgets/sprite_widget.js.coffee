class App.Views.SpriteWidget extends Backbone.View
  template: JST['app/templates/widgets/sprite_widget']

  tagName:  'li'


  render: ->
    @$el.html @template(widget: @model)
    @
