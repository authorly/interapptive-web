class App.Views.SpriteWidget extends Backbone.View
  template: JST['app/templates/widgets/sprite_widget']

  tagName:  'li'

  events:
    'click': "setActiveImage"


  render: ->
    @$el.html @template(widget: @options.widget)
    @


  setActiveImage: (event) ->
    $(event.target).closest('li').
      addClass('active').
      siblings().
      removeClass('active')


