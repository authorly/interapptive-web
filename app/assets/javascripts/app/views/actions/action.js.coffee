class App.Views.Action extends Backbone.View
  template: JST['app/templates/actions/action']

  tagName: 'li'


  render: =>
    @$el.html(@template(action: @model))

    @
