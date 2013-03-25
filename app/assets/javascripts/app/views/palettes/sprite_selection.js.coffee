class App.Views.SpriteSelectionPalette extends Backbone.View
  template: JST['app/templates/palettes/sprite_selection']
  tagname: 'ul'

  openStorybook: (storybook) ->
    console.log('called')
